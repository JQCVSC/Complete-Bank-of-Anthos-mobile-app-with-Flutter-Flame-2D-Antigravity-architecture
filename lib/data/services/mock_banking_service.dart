import 'dart:math';
import '../models/user_profile.dart';
import '../models/account_balance.dart';
import '../models/transaction.dart';
import '../models/contact.dart';
import 'storage_service.dart';

class MockBankingService {
  final StorageService _storage;

  MockBankingService(this._storage);

  static const String defaultTestUser = 'testuser';
  static const String defaultPassword = 'password123';

  Future<UserProfile> login(String username, String password) async {
    // Artificial latency for realism
    await Future.delayed(const Duration(milliseconds: 600));

    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username and password are required');
    }

    final user = UserProfile(
      accountId: '1012345678',
      username: username,
      displayName: username.toLowerCase() == 'testuser' ? 'Alice Jackson' : username,
      email: '$username@bankofanthos.com',
      routingNumber: '123456789',
      token: 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
    );

    await _storage.saveUserProfile(user);
    await _storage.saveToken(user.token!);
    _ensureSeedData();
    return user;
  }

  Future<UserProfile> signup({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate random 10-digit account ID
    final randomAcct = '10${Random().nextInt(89999999) + 10000000}';
    final user = UserProfile(
      accountId: randomAcct,
      username: username,
      displayName: '$firstName $lastName'.trim(),
      email: email.isNotEmpty ? email : '$username@bankofanthos.com',
      routingNumber: '123456789',
      token: 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
    );

    await _storage.saveUserProfile(user);
    await _storage.saveToken(user.token!);
    _initNewUserSeed(user.accountId);
    return user;
  }

  Future<AccountBalance> getBalance(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cents = _storage.getMockBalanceCents() ?? 1245075; // Default: $12,450.75
    return AccountBalance(
      balanceCents: cents,
      accountId: accountId,
      lastUpdated: DateTime.now(),
    );
  }

  Future<List<BankTransaction>> getTransactions(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final cached = _storage.getMockTransactions();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final initialTxs = _generateInitialTransactions(accountId);
    await _storage.setMockTransactions(initialTxs);
    return initialTxs;
  }

  Future<List<Contact>> getContacts(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cached = _storage.getMockContacts();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final initialContacts = _generateInitialContacts();
    await _storage.setMockContacts(initialContacts);
    return initialContacts;
  }

  Future<BankTransaction> sendPayment({
    required String fromAccountId,
    required String toAccountId,
    required int amountCents,
    String? accountLabel,
    String fromRoutingNum = '123456789',
    String toRoutingNum = '123456789',
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final currentBalance = _storage.getMockBalanceCents() ?? 1245075;
    if (currentBalance < amountCents) {
      throw Exception('Insufficient funds for this transaction.');
    }

    final newBalance = currentBalance - amountCents;
    await _storage.setMockBalanceCents(newBalance);

    final newTx = BankTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      fromAccountNum: fromAccountId,
      toAccountNum: toAccountId,
      fromRoutingNum: fromRoutingNum,
      toRoutingNum: toRoutingNum,
      amountCents: amountCents,
      timestamp: DateTime.now(),
      accountLabel: accountLabel ?? 'Payment to $toAccountId',
    );

    final existing = await getTransactions(fromAccountId);
    final updated = [newTx, ...existing];
    await _storage.setMockTransactions(updated);

    return newTx;
  }

  Future<BankTransaction> deposit({
    required String accountId,
    required int amountCents,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final currentBalance = _storage.getMockBalanceCents() ?? 1245075;
    final newBalance = currentBalance + amountCents;
    await _storage.setMockBalanceCents(newBalance);

    final newTx = BankTransaction(
      id: 'dep-${DateTime.now().millisecondsSinceEpoch}',
      fromAccountNum: '0000000000',
      toAccountNum: accountId,
      amountCents: amountCents,
      timestamp: DateTime.now(),
      accountLabel: 'Mobile Check / Cash Deposit',
    );

    final existing = await getTransactions(accountId);
    final updated = [newTx, ...existing];
    await _storage.setMockTransactions(updated);

    return newTx;
  }

  Future<Contact> addContact({
    required String username,
    required String label,
    required String accountNum,
    String routingNum = '123456789',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newContact = Contact(
      label: label,
      accountNum: accountNum,
      routingNum: routingNum,
    );

    final existing = await getContacts(username);
    final updated = [...existing, newContact];
    await _storage.setMockContacts(updated);

    return newContact;
  }

  void _ensureSeedData() {
    if (_storage.getMockBalanceCents() == null) {
      _storage.setMockBalanceCents(1245075); // $12,450.75
    }
  }

  void _initNewUserSeed(String accountId) {
    _storage.setMockBalanceCents(500000); // $5,000.00 starting balance
    final txs = [
      BankTransaction(
        id: 'init-1',
        fromAccountNum: '0000000000',
        toAccountNum: accountId,
        amountCents: 500000,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        accountLabel: 'Welcome Deposit Bonus',
      ),
    ];
    _storage.setMockTransactions(txs);
  }

  List<BankTransaction> _generateInitialTransactions(String accountId) {
    final now = DateTime.now();
    return [
      BankTransaction(
        id: 'tx-101',
        fromAccountNum: '8812349081',
        toAccountNum: accountId,
        amountCents: 350000, // $3,500.00
        timestamp: now.subtract(const Duration(hours: 4)),
        accountLabel: 'Anthos Global Payroll Direct Deposit',
      ),
      BankTransaction(
        id: 'tx-102',
        fromAccountNum: accountId,
        toAccountNum: '2019482103',
        amountCents: 14520, // $145.20
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        accountLabel: 'Cymbal Clean Energy Utility',
      ),
      BankTransaction(
        id: 'tx-103',
        fromAccountNum: accountId,
        toAccountNum: '3948201948',
        amountCents: 8550, // $85.50
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        accountLabel: 'Payment to Charlie Patel',
      ),
      BankTransaction(
        id: 'tx-104',
        fromAccountNum: '4820194820',
        toAccountNum: accountId,
        amountCents: 12000, // $120.00
        timestamp: now.subtract(const Duration(days: 4)),
        accountLabel: 'Transfer from Bob Jones',
      ),
      BankTransaction(
        id: 'tx-105',
        fromAccountNum: accountId,
        toAccountNum: '9182301928',
        amountCents: 45000, // $450.00
        timestamp: now.subtract(const Duration(days: 6)),
        accountLabel: 'Mountain View Grocery Market',
      ),
      BankTransaction(
        id: 'tx-106',
        fromAccountNum: '0000000000',
        toAccountNum: accountId,
        amountCents: 200000, // $2,000.00
        timestamp: now.subtract(const Duration(days: 10)),
        accountLabel: 'Mobile Check Deposit',
      ),
    ];
  }

  List<Contact> _generateInitialContacts() {
    return const [
      Contact(
        label: 'Bob Jones',
        accountNum: '4820194820',
        routingNum: '123456789',
      ),
      Contact(
        label: 'Charlie Patel',
        accountNum: '3948201948',
        routingNum: '123456789',
      ),
      Contact(
        label: 'Cymbal Clean Energy',
        accountNum: '2019482103',
        routingNum: '123456789',
        isExternal: true,
      ),
      Contact(
        label: 'Anthos Payroll',
        accountNum: '8812349081',
        routingNum: '123456789',
      ),
      Contact(
        label: 'Sarah Connor',
        accountNum: '7729103948',
        routingNum: '123456789',
      ),
    ];
  }
}

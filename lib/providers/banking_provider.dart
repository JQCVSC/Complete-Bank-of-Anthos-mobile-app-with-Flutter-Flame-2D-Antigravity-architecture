import 'package:flutter/material.dart';
import '../data/models/account_balance.dart';
import '../data/models/transaction.dart';
import '../data/models/contact.dart';
import '../data/repositories/banking_repository.dart';
import '../data/repositories/contacts_repository.dart';

enum TransactionFilter {
  all,
  inflow,
  outflow,
}

class BankingProvider extends ChangeNotifier {
  final BankingRepository _bankingRepository;
  final ContactsRepository _contactsRepository;

  AccountBalance? _balance;
  List<BankTransaction> _transactions = [];
  List<Contact> _contacts = [];

  bool _isLoading = false;
  bool _isProcessingAction = false;
  String? _errorMessage;
  String? _successMessage;

  TransactionFilter _currentFilter = TransactionFilter.all;
  String _searchQuery = '';

  BankingProvider({
    required BankingRepository bankingRepository,
    required ContactsRepository contactsRepository,
  })  : _bankingRepository = bankingRepository,
        _contactsRepository = contactsRepository;

  AccountBalance? get balance => _balance;
  List<BankTransaction> get allTransactions => _transactions;
  List<Contact> get contacts => _contacts;

  bool get isLoading => _isLoading;
  bool get isProcessingAction => _isProcessingAction;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  TransactionFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  List<BankTransaction> get filteredTransactions {
    return _transactions.where((tx) {
      final currentAccount = _balance?.accountId ?? '';

      // Filter by type
      if (_currentFilter == TransactionFilter.inflow && !tx.isInflow(currentAccount)) {
        return false;
      }
      if (_currentFilter == TransactionFilter.outflow && !tx.isOutflow(currentAccount)) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = tx.displayTitle(currentAccount).toLowerCase();
        final id = tx.id.toLowerCase();
        final toAcct = tx.toAccountNum.toLowerCase();
        final fromAcct = tx.fromAccountNum.toLowerCase();
        return title.contains(query) || id.contains(query) || toAcct.contains(query) || fromAcct.contains(query);
      }

      return true;
    }).toList();
  }

  void setFilter(TransactionFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> refreshAll(String accountId, String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final balanceFuture = _bankingRepository.getBalance(accountId);
      final txFuture = _bankingRepository.getTransactions(accountId);
      final contactsFuture = _contactsRepository.getContacts(username);

      final results = await Future.wait([balanceFuture, txFuture, contactsFuture]);

      _balance = results[0] as AccountBalance;
      _transactions = results[1] as List<BankTransaction>;
      _contacts = results[2] as List<Contact>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> sendPayment({
    required String fromAccountId,
    required String toAccountId,
    required int amountCents,
    String? accountLabel,
    required String username,
  }) async {
    _isProcessingAction = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _bankingRepository.sendPayment(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amountCents: amountCents,
        accountLabel: accountLabel,
      );

      _successMessage = 'Payment sent successfully!';
      _isProcessingAction = false;
      await refreshAll(fromAccountId, username);
      return true;
    } catch (e) {
      _isProcessingAction = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deposit({
    required String accountId,
    required int amountCents,
    required String username,
  }) async {
    _isProcessingAction = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _bankingRepository.deposit(
        accountId: accountId,
        amountCents: amountCents,
      );

      _successMessage = 'Funds deposited successfully!';
      _isProcessingAction = false;
      await refreshAll(accountId, username);
      return true;
    } catch (e) {
      _isProcessingAction = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addContact({
    required String username,
    required String label,
    required String accountNum,
    String routingNum = '123456789',
  }) async {
    _isProcessingAction = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _contactsRepository.addContact(
        username: username,
        label: label,
        accountNum: accountNum,
        routingNum: routingNum,
      );

      _successMessage = 'Contact added successfully!';
      _isProcessingAction = false;
      final updatedContacts = await _contactsRepository.getContacts(username);
      _contacts = updatedContacts;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessingAction = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}

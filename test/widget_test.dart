import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_of_anthos_mobile/core/utils/currency_formatter.dart';
import 'package:bank_of_anthos_mobile/core/utils/date_formatter.dart';
import 'package:bank_of_anthos_mobile/data/models/contact.dart';
import 'package:bank_of_anthos_mobile/data/models/transaction.dart';
import 'package:bank_of_anthos_mobile/data/services/storage_service.dart';
import 'package:bank_of_anthos_mobile/data/services/mock_banking_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyFormatter tests', () {
    test('formatCents converts cents into USD string correctly', () {
      expect(CurrencyFormatter.formatCents(1245075), '\$12,450.75');
      expect(CurrencyFormatter.formatCents(0), '\$0.00');
      expect(CurrencyFormatter.formatCents(50), '\$0.50');
      expect(CurrencyFormatter.formatCents(null), '\$0.00');
    });

    test('parseDollarsToCents parses string inputs into integer cents', () {
      expect(CurrencyFormatter.parseDollarsToCents('12450.75'), 1245075);
      expect(CurrencyFormatter.parseDollarsToCents('\$1,500.00'), 150000);
      expect(CurrencyFormatter.parseDollarsToCents('0.50'), 50);
      expect(CurrencyFormatter.parseDollarsToCents('invalid'), 0);
    });
  });

  group('DateFormatter tests', () {
    test('formats dates correctly', () {
      final date = DateTime(2026, 9, 29, 14, 30);
      expect(DateFormatter.formatDate(date), contains('Sep 29, 2026'));
      expect(DateFormatter.formatTime(date), isNotEmpty);
    });
  });

  group('Domain Model tests', () {
    test('Contact generates proper initials and JSON serialization', () {
      const contact1 = Contact(
        label: 'Alice Jackson',
        accountNum: '1012345678',
        routingNum: '123456789',
      );
      expect(contact1.initials, 'AJ');

      const contact2 = Contact(
        label: 'Anthos',
        accountNum: '9988776655',
      );
      expect(contact2.initials, 'A');

      final json = contact1.toJson();
      final fromJson = Contact.fromJson(json);
      expect(fromJson.label, 'Alice Jackson');
      expect(fromJson.accountNum, '1012345678');
    });

    test('BankTransaction properly determines inflow vs outflow and formatting', () {
      final tx = BankTransaction(
        id: 'tx-test-1',
        fromAccountNum: '1012345678',
        toAccountNum: '2023456789',
        amountCents: 5000, // $50.00
        timestamp: DateTime.now(),
        accountLabel: 'Coffee',
      );

      // Viewed from sender
      expect(tx.isOutflow('1012345678'), isTrue);
      expect(tx.isInflow('1012345678'), isFalse);
      expect(tx.formattedAmount(currentAccountId: '1012345678'), '-\$50.00');

      // Viewed from recipient
      expect(tx.isOutflow('2023456789'), isFalse);
      expect(tx.isInflow('2023456789'), isTrue);
      expect(tx.formattedAmount(currentAccountId: '2023456789'), '+\$50.00');
    });
  });

  group('MockBankingService integration test', () {
    test('Login and transactions flow works', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final service = MockBankingService(storage);

      // Login
      final user = await service.login('testuser', 'password123');
      expect(user.username, 'testuser');
      expect(user.accountId, '1012345678');

      // Balance
      final balance = await service.getBalance(user.accountId);
      expect(balance.balanceCents, greaterThan(0));

      // Transactions
      final txs = await service.getTransactions(user.accountId);
      expect(txs, isNotEmpty);

      // Contacts
      final contacts = await service.getContacts(user.username);
      expect(contacts, isNotEmpty);

      // Send money
      final initialBalance = balance.balanceCents;
      final sentTx = await service.sendPayment(
        fromAccountId: user.accountId,
        toAccountId: '3948201948',
        amountCents: 10000, // $100.00
      );
      expect(sentTx.amountCents, 10000);

      final newBalance = await service.getBalance(user.accountId);
      expect(newBalance.balanceCents, initialBalance - 10000);
    });
  });
}

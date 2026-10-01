import '../models/account_balance.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/mock_banking_service.dart';
import '../services/storage_service.dart';

class BankingRepository {
  final ApiService _apiService;
  final MockBankingService _mockService;
  final StorageService _storageService;

  BankingRepository({
    required ApiService apiService,
    required MockBankingService mockService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _mockService = mockService,
        _storageService = storageService;

  Future<AccountBalance> getBalance(String accountId) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      return _mockService.getBalance(accountId);
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final token = _storageService.getToken() ?? '';
      return _apiService.getBalance(
        baseUrl: baseUrl,
        accountId: accountId,
        token: token,
      );
    }
  }

  Future<List<BankTransaction>> getTransactions(String accountId) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      return _mockService.getTransactions(accountId);
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final token = _storageService.getToken() ?? '';
      return _apiService.getTransactions(
        baseUrl: baseUrl,
        accountId: accountId,
        token: token,
      );
    }
  }

  Future<void> sendPayment({
    required String fromAccountId,
    required String toAccountId,
    required int amountCents,
    String? accountLabel,
    String fromRoutingNum = '123456789',
    String toRoutingNum = '123456789',
  }) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      await _mockService.sendPayment(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amountCents: amountCents,
        accountLabel: accountLabel,
        fromRoutingNum: fromRoutingNum,
        toRoutingNum: toRoutingNum,
      );
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final token = _storageService.getToken() ?? '';
      await _apiService.sendPayment(
        baseUrl: baseUrl,
        token: token,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amountCents: amountCents,
        fromRoutingNum: fromRoutingNum,
        toRoutingNum: toRoutingNum,
      );
    }
  }

  Future<void> deposit({
    required String accountId,
    required int amountCents,
  }) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      await _mockService.deposit(
        accountId: accountId,
        amountCents: amountCents,
      );
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final token = _storageService.getToken() ?? '';
      await _apiService.deposit(
        baseUrl: baseUrl,
        token: token,
        accountId: accountId,
        amountCents: amountCents,
      );
    }
  }
}

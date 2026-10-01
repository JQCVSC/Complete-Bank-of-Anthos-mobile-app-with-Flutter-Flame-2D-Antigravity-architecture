import '../models/contact.dart';
import '../services/api_service.dart';
import '../services/mock_banking_service.dart';
import '../services/storage_service.dart';

class ContactsRepository {
  final ApiService _apiService;
  final MockBankingService _mockService;
  final StorageService _storageService;

  ContactsRepository({
    required ApiService apiService,
    required MockBankingService mockService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _mockService = mockService,
        _storageService = storageService;

  Future<List<Contact>> getContacts(String username) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      return _mockService.getContacts(username);
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final token = _storageService.getToken() ?? '';
      return _apiService.getContacts(
        baseUrl: baseUrl,
        username: username,
        token: token,
      );
    }
  }

  Future<Contact> addContact({
    required String username,
    required String label,
    required String accountNum,
    String routingNum = '123456789',
  }) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      return _mockService.addContact(
        username: username,
        label: label,
        accountNum: accountNum,
        routingNum: routingNum,
      );
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final token = _storageService.getToken() ?? '';
      await _apiService.addContact(
        baseUrl: baseUrl,
        token: token,
        username: username,
        label: label,
        accountNum: accountNum,
        routingNum: routingNum,
      );
      return Contact(label: label, accountNum: accountNum, routingNum: routingNum);
    }
  }
}

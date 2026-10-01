import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/mock_banking_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final MockBankingService _mockService;
  final StorageService _storageService;

  AuthRepository({
    required ApiService apiService,
    required MockBankingService mockService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _mockService = mockService,
        _storageService = storageService;

  UserProfile? getCurrentUser() {
    return _storageService.getUserProfile();
  }

  bool isAuthenticated() {
    return _storageService.getToken() != null && _storageService.getUserProfile() != null;
  }

  Future<UserProfile> login({
    required String username,
    required String password,
  }) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      return _mockService.login(username, password);
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final user = await _apiService.login(
        baseUrl: baseUrl,
        username: username,
        password: password,
      );
      if (user.token != null) {
        await _storageService.saveToken(user.token!);
      }
      await _storageService.saveUserProfile(user);
      return user;
    }
  }

  Future<UserProfile> signup({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final isDemo = _storageService.isDemoMode();
    if (isDemo) {
      return _mockService.signup(
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
    } else {
      final baseUrl = _storageService.getBaseUrl();
      final user = await _apiService.signup(
        baseUrl: baseUrl,
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      if (user.token != null) {
        await _storageService.saveToken(user.token!);
      }
      await _storageService.saveUserProfile(user);
      return user;
    }
  }

  Future<void> logout() async {
    await _storageService.clearToken();
    await _storageService.clearUserProfile();
  }
}

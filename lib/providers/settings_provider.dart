import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';
import '../data/services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  final ApiService _apiService;

  late bool _isDemoMode;
  late String _baseUrl;
  bool _isCheckingHealth = false;
  bool? _isClusterHealthy;
  ThemeMode _themeMode = ThemeMode.dark;

  SettingsProvider({
    required StorageService storage,
    required ApiService apiService,
  })  : _storage = storage,
        _apiService = apiService {
    _isDemoMode = _storage.isDemoMode();
    _baseUrl = _storage.getBaseUrl();
  }

  bool get isDemoMode => _isDemoMode;
  String get baseUrl => _baseUrl;
  bool get isCheckingHealth => _isCheckingHealth;
  bool? get isClusterHealthy => _isClusterHealthy;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> toggleDemoMode(bool value) async {
    _isDemoMode = value;
    await _storage.setDemoMode(value);
    notifyListeners();
  }

  Future<void> updateBaseUrl(String url) async {
    _baseUrl = url.trim();
    await _storage.setBaseUrl(_baseUrl);
    _isClusterHealthy = null;
    notifyListeners();
  }

  Future<void> checkClusterHealth() async {
    _isCheckingHealth = true;
    _isClusterHealthy = null;
    notifyListeners();

    try {
      final healthy = await _apiService.checkHealth(_baseUrl);
      _isClusterHealthy = healthy;
    } catch (_) {
      _isClusterHealthy = false;
    } finally {
      _isCheckingHealth = false;
      notifyListeners();
    }
  }

  Future<void> resetDemoData() async {
    await _storage.setMockBalanceCents(1245075);
    await _storage.setMockTransactions([]);
    await _storage.setMockContacts([]);
    notifyListeners();
  }
}

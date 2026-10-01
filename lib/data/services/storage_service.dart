import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/transaction.dart';
import '../models/contact.dart';

class StorageService {
  static const String _keyToken = 'boa_auth_token';
  static const String _keyUser = 'boa_user_profile';
  static const String _keyBaseUrl = 'boa_base_url';
  static const String _keyIsDemoMode = 'boa_is_demo_mode';
  static const String _keyMockBalance = 'boa_mock_balance_cents';
  static const String _keyMockTransactions = 'boa_mock_transactions';
  static const String _keyMockContacts = 'boa_mock_contacts';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  UserProfile? getUserProfile() {
    final data = _prefs.getString(_keyUser);
    if (data == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserProfile() async {
    await _prefs.remove(_keyUser);
  }

  // Environment Settings
  bool isDemoMode() {
    return _prefs.getBool(_keyIsDemoMode) ?? true; // Default to demo mode for instant reliability
  }

  Future<void> setDemoMode(bool isDemo) async {
    await _prefs.setBool(_keyIsDemoMode, isDemo);
  }

  String getBaseUrl() {
    return _prefs.getString(_keyBaseUrl) ?? 'http://10.0.2.2:8080';
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  // Mock Data Persistence (for seamless sandbox state)
  int? getMockBalanceCents() {
    return _prefs.getInt(_keyMockBalance);
  }

  Future<void> setMockBalanceCents(int cents) async {
    await _prefs.setInt(_keyMockBalance, cents);
  }

  List<BankTransaction>? getMockTransactions() {
    final raw = _prefs.getString(_keyMockTransactions);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => BankTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> setMockTransactions(List<BankTransaction> txs) async {
    final encoded = jsonEncode(txs.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyMockTransactions, encoded);
  }

  List<Contact>? getMockContacts() {
    final raw = _prefs.getString(_keyMockContacts);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> setMockContacts(List<Contact> contacts) async {
    final encoded = jsonEncode(contacts.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyMockContacts, encoded);
  }

  Future<void> resetAll() async {
    await _prefs.clear();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/account_balance.dart';
import '../models/transaction.dart';
import '../models/contact.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
      map['Cookie'] = 'token=$token';
    }
    return map;
  }

  Future<bool> checkHealth(String baseUrl) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiEndpoints.readiness}');
      final response = await _client.get(uri).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<UserProfile> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.login}');
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // In Bank of Anthos, login sets a cookie 'token' or returns JSON
      String token = '';
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        final match = RegExp(r'token=([^;]+)').firstMatch(rawCookie);
        if (match != null) {
          token = match.group(1)!;
        }
      }

      Map<String, dynamic> bodyData = {};
      try {
        bodyData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      return UserProfile(
        accountId: bodyData['acct']?.toString() ??
            bodyData['account_id']?.toString() ??
            '1012345678',
        username: username,
        displayName: bodyData['name']?.toString() ?? username,
        email: bodyData['email']?.toString() ?? '$username@bankofanthos.com',
        routingNumber: '123456789',
        token: token.isNotEmpty ? token : bodyData['token']?.toString() ?? 'live-token',
      );
    } else {
      throw Exception('Login failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<UserProfile> signup({
    required String baseUrl,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.signup}');
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'username': username,
        'password': password,
        'password_repeat': password,
        'firstname': firstName,
        'lastname': lastName,
        'birthday': '1990-01-01',
        'timezone': 'America/Los_Angeles',
        'address': '1600 Amphitheatre Pkwy',
        'email': email,
        'ssn': '123456789',
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return login(baseUrl: baseUrl, username: username, password: password);
    } else {
      throw Exception('Registration failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<AccountBalance> getBalance({
    required String baseUrl,
    required String accountId,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.balance}/$accountId');
    final response = await _client.get(
      uri,
      headers: _headers(token: token),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      dynamic raw;
      try {
        raw = jsonDecode(response.body);
      } catch (_) {
        raw = response.body;
      }
      return AccountBalance.fromRaw(raw, accountId);
    } else {
      throw Exception('Failed to fetch balance: ${response.statusCode}');
    }
  }

  Future<List<BankTransaction>> getTransactions({
    required String baseUrl,
    required String accountId,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.transactions}/$accountId');
    final response = await _client.get(
      uri,
      headers: _headers(token: token),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => BankTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch transactions: ${response.statusCode}');
    }
  }

  Future<List<Contact>> getContacts({
    required String baseUrl,
    required String username,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.contacts}/$username');
    final response = await _client.get(
      uri,
      headers: _headers(token: token),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch contacts: ${response.statusCode}');
    }
  }

  Future<void> sendPayment({
    required String baseUrl,
    required String token,
    required String fromAccountId,
    required String toAccountId,
    required int amountCents,
    String fromRoutingNum = '123456789',
    String toRoutingNum = '123456789',
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.payment}');
    final response = await _client.post(
      uri,
      headers: _headers(token: token),
      body: jsonEncode({
        'from_account_num': fromAccountId,
        'to_account_num': toAccountId,
        'amount': amountCents,
        'orig_routing_num': fromRoutingNum,
        'dest_routing_num': toRoutingNum,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Payment transaction failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deposit({
    required String baseUrl,
    required String token,
    required String accountId,
    required int amountCents,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.deposit}');
    final response = await _client.post(
      uri,
      headers: _headers(token: token),
      body: jsonEncode({
        'account_id': accountId,
        'amount': amountCents,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Deposit failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> addContact({
    required String baseUrl,
    required String token,
    required String username,
    required String label,
    required String accountNum,
    String routingNum = '123456789',
  }) async {
    final uri = Uri.parse('$baseUrl${ApiEndpoints.contacts}/$username');
    final response = await _client.post(
      uri,
      headers: _headers(token: token),
      body: jsonEncode({
        'label': label,
        'account_num': accountNum,
        'routing_num': routingNum,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add contact: ${response.statusCode}');
    }
  }
}

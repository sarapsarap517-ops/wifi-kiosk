import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) return override;

    return 'http://10.0.2.2:3000/api';
  }

  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async => _storage.read(key: 'jwt');

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(
    String accountNo,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account_no': accountNo,
        'password': password,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      final token = data['token'];

      if (token != null && token.toString().isNotEmpty) {
        await _storage.write(key: 'jwt', value: token.toString());
      }

      return data;
    }

    throw Exception(data['error'] ?? 'فشل تسجيل الدخول');
  }

  static Future<List<dynamic>> getNetworks({
    String search = '',
    bool favOnly = false,
  }) async {
    final headers = await _headers();
    final uri = Uri.parse(
      '$baseUrl/networks?search=${Uri.encodeComponent(search)}&fav=${favOnly ? 1 : 0}',
    );

    final res = await http.get(uri, headers: headers);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }

    throw Exception('فشل جلب قائمة الشبكات');
  }

  static Future<Map<String, dynamic>> buyCard(int categoryId) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl/cards/$categoryId/sell');

    final res = await http.post(uri, headers: headers);
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data;
    }

    throw Exception(data['error'] ?? 'فشل الشراء');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // قم بتغيير هذا الرابط لاحقاً لرابط سيرفرك أونلاين
  static const String baseUrl = 'http://localhost:3000/api'; 
  static const _storage = FlutterSecureStorage();

  // جلب التوكين المحفوظ
  static Future<String?> getToken() async => await _storage.read(key: 'jwt');

  // إعداد الهيدر المعياري
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. تسجيل الدخول
  static Future<Map<String, dynamic>> login(String accountNo, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'account_no': accountNo, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await _storage.write(key: 'jwt', value: data['token']);
      return data;
    }
    throw Exception(data['error'] ?? 'فشل تسجيل الدخول');
  }

  // 2. جلب قائمة الشبكات
  static Future<List<dynamic>> getNetworks({String search = '', bool favOnly = false}) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl/networks?search=$search&fav=${favOnly ? 1 : 0}');
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('فشل جلب قائمة الشبكات');
  }

  // 3. شراء كرت تلقائي من فئة
  static Future<Map<String, dynamic>> buyCard(int categoryId) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('$baseUrl/categories/$categoryId/buy-one'),
      headers: headers,
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data;
    throw Exception(data['error'] ?? 'فشل الشراء');
  }
}

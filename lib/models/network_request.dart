import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryModel {
  String name;
  double price;
  double margin;
  int remaining;
  int sold;

  CategoryModel({
    required this.name,
    required this.price,
    required this.margin,
    this.remaining = 0, // قيمة افتراضية لتجنب خطأ البناء
    this.sold = 0,      // قيمة افتراضية
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'margin': margin,
        'remaining': remaining,
        'sold': sold,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        name: json['name'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        margin: (json['margin'] as num?)?.toDouble() ?? 0.0,
        remaining: json['remaining'] ?? 0,
        sold: json['sold'] ?? 0,
      );
}

class NetworkRequest {
  String id;
  String networkName;
  String city;
  String phone;
  String status;
  List<CategoryModel> categories;

  NetworkRequest({
    required this.id,
    required this.networkName,
    required this.city,
    required this.phone,
    required this.status,
    required this.categories,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'networkName': networkName,
        'city': city,
        'phone': phone,
        'status': status,
        'categories': categories.map((c) => c.toJson()).toList(),
      };

  factory NetworkRequest.fromJson(Map<String, dynamic> json) => NetworkRequest(
        id: json['id'] ?? '',
        networkName: json['networkName'] ?? '',
        city: json['city'] ?? '',
        phone: json['phone'] ?? '',
        status: json['status'] ?? '',
        categories: (json['categories'] as List? ?? [])
            .map((c) => CategoryModel.fromJson(c))
            .toList(),
      );
}

class NetworkDataStore {
  static List<NetworkRequest> requests = [];

  // حفظ البيانات محلياً
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(requests.map((e) => e.toJson()).toList());
    await prefs.setString('saved_networks', encodedData);
  }

  // تحميل البيانات عند فتح التطبيق
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_networks');
    if (savedData != null && savedData.isNotEmpty) {
      final List decodedList = jsonDecode(savedData);
      requests = decodedList.map((e) => NetworkRequest.fromJson(e)).toList();
    }
  }
}

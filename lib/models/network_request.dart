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
    required this.remaining,
    required this.sold,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'margin': margin,
      'remaining': remaining,
      'sold': sold,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      margin: (json['margin'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
    );
  }
}

class NetworkRequest {
  String id;
  String networkName;
  String ownerName;
  String city;
  String phone;
  String status;
  List<CategoryModel> categories;

  NetworkRequest({
    required this.id,
    required this.networkName,
    required this.ownerName,
    required this.city,
    required this.phone,
    required this.status,
    required this.categories,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'networkName': networkName,
      'ownerName': ownerName,
      'city': city,
      'phone': phone,
      'status': status,
      'categories': categories.map((category) {
        return category.toJson();
      }).toList(),
    };
  }

  factory NetworkRequest.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'];

    return NetworkRequest(
      id: json['id']?.toString() ?? '',
      networkName: json['networkName']?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'قيد الانتظار',
      categories: categoriesJson is List
          ? categoriesJson
              .whereType<Map>()
              .map((category) {
                return CategoryModel.fromJson(
                  Map<String, dynamic>.from(category),
                );
              })
              .toList()
          : <CategoryModel>[],
    );
  }
}

class NetworkDataStore {
  static List<NetworkRequest> requests = [];

  static Future<void> saveData() async {
    final preferences = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      requests.map((request) {
        return request.toJson();
      }).toList(),
    );

    await preferences.setString('saved_networks', encodedData);
  }

  static Future<void> loadData() async {
    final preferences = await SharedPreferences.getInstance();

    final savedData = preferences.getString('saved_networks');

    if (savedData == null || savedData.isEmpty) {
      requests = [];
      return;
    }

    try {
      final decodedData = jsonDecode(savedData);

      if (decodedData is List) {
        requests = decodedData
            .whereType<Map>()
            .map((item) {
              return NetworkRequest.fromJson(
                Map<String, dynamic>.from(item),
              );
            })
            .toList();
      }
    } catch (_) {
      requests = [];
    }
  }
}

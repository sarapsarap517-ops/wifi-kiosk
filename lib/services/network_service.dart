import 'package:flutter/material.dart';

class NetworkItem {
  final String id;
  final String name;
  final String info;
  bool isFavorite;

  NetworkItem({
    required this.id,
    required this.name,
    required this.info,
    this.isFavorite = false,
  });
}

class NetworkService {
  // القائمة الافتراضية للشبكات من الصورة
  static final List<NetworkItem> defaultNetworks = [
    NetworkItem(id: '0', name: 'لايف تك', info: 'تعز- الحوبان - تلفون 736878267'),
    NetworkItem(id: '1', name: 'شبكة نايس نت', info: 'NICE - تعز-الحوبان - تلفون 773026984'),
    NetworkItem(id: '2', name: 'شبكة العمري نت', info: 'اب - المدينة - تلفون 711908750'),
    NetworkItem(id: '3', name: 'شاهد نت', info: 'تعز-الحوبان - تلفون 733009598'),
    NetworkItem(id: '4', name: 'شبكة البرق', info: 'تعز- الحوبان - تلفون 738918582'),
    NetworkItem(id: '5', name: 'شبكة الاتفاق', info: 'دير الحبيلي-تلفون 717509045'),
    NetworkItem(id: '6', name: 'شبكة العلاوي نت', info: 'تلفون 770000000'),
  ];

  // دالة إضافة شبكة جديدة ديناميكياً
  static void addNetwork({
    required String networkName,
    required String phone,
    required String region,
  }) {
    String newId = defaultNetworks.length.toString();
    defaultNetworks.add(
      NetworkItem(
        id: newId,
        name: networkName,
        info: '$region - تلفون $phone',
      ),
    );
  }
}

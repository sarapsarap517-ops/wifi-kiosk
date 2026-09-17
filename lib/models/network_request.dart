class NetworkRequest {
  final String id;
  final String ownerName;
  final String phone;
  final String networkName;
  final String city;
  String status; // 'معلق', 'مقبول', 'مرفوض'

  NetworkRequest({
    required this.id,
    required this.ownerName,
    required this.phone,
    required this.networkName,
    required this.city,
    this.status = 'معلق',
  });
}

// ذاكرة مؤقتة للطلبات
class NetworkDataStore {
  static List<NetworkRequest> requests = [
    NetworkRequest(
      id: '1',
      ownerName: 'أحمد علي',
      phone: '770000000',
      networkName: 'شبكة الأمل',
      city: 'صنعاء',
    ),
  ];
}

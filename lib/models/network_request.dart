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
    this.remaining = 0,
    this.sold = 0,
  });
}

class NetworkRequest {
  final String id; // رقم الشبكة / الرقم التسلسلي
  final String networkName;
  final String ownerName;
  final String phone;
  final String city;
  String status; // 'قيد الانتظار', 'مقبول', 'مرفوض'
  List<CategoryModel> categories; // تبدأ فارغة تماماً

  NetworkRequest({
    required this.id,
    required this.networkName,
    required this.ownerName,
    required this.phone,
    required this.city,
    this.status = 'قيد الانتظار',
    List<CategoryModel>? categories,
  }) : categories = categories ?? [];
}

class NetworkDataStore {
  // القائمة فارغة تماماً وتتغذى ديناميكياً من نموذج طلب إضافة شبكة
  static List<NetworkRequest> requests = [];
}

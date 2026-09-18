import 'package:flutter/material.dart';
import '../models/network_request.dart';
import 'add_network_screen.dart';

// نموذج الفئة ديناميكي يبدأ بدون أرقام وهمية
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

class NetworksGalleryScreen extends StatefulWidget {
  const NetworksGalleryScreen({super.key});

  @override
  State<NetworksGalleryScreen> createState() => _NetworksGalleryScreenState();
}

class _NetworksGalleryScreenState extends State<NetworksGalleryScreen> {
  // قائمة الفئات المضافة (تبدأ فارغة ويضيفها المستخدم حسب شبكته)
  List<CategoryModel> categories = [];

  final _catNameController = TextEditingController();
  final _catPriceController = TextEditingController();
  final _catMarginController = TextEditingController();
  final _cardsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // تصفية الشبكات المقبولة فقط من الأدمن
    final approvedRequests = NetworkDataStore.requests.where((r) => r.status == 'مقبول').toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معرض شبكاتي'),
          backgroundColor: const Color(0xFF5A3192),
          centerTitle: true,
        ),
        body: approvedRequests.isEmpty
            ? _buildNoNetworkView(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: approvedRequests.length,
                itemBuilder: (context, index) {
                  final net = approvedRequests[index];
                  return _buildNetworkCard(net);
                },
              ),
      ),
    );
  }

  // 1. واجهة في حال عدم وجود شبكات معتمدة
  Widget _buildNoNetworkView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'لا توجد لديك شبكات معتمدة حتى الآن',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'قم بتقديم طلب إضافة شبكتك مجاناً وانتظار موافقة الإدارة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A3192),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNetworkScreen()),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'أضف شبكتك مجاناً',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. بطاقة الشبكة المقبولة
  Widget _buildNetworkCard(NetworkRequest net) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'شبكة ${net.networkName} ( ${net.city} - ${net.phone} )',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('رقم الهاتف: ${net.phone}', style: const TextStyle(fontSize: 13)),
            Text('رقم الشبكة: ${net.id}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.card_giftcard, 'الكروت', () {
                  if (categories.isEmpty) {
                    _showNoCategoriesAlert();
                  } else {
                    _showAddCardsDialog(categories.first);
                  }
                }),
                _buildActionButton(Icons.ac_unit, 'الفئات', () => _showCategoriesDialog()),
                _buildActionButton(Icons.warning_amber_rounded, 'تقرير + إضافة الكروت', () => _showReportAndAddCardsSheet(net)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE7),
          border: Border.all(color: Colors.amber.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // تنبيه في حال عدم وجود فئات
  void _showNoCategoriesAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى إضافة الفئات أولاً من زر (الفئات)')),
    );
  }

  // 3. نافذة إدارة الفئات والأسعار
  void _showCategoriesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20, left: 16, right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('إضافة فئة جديدة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _catNameController,
                            decoration: const InputDecoration(labelText: 'الفئة *', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _catPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'السعر *', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _catMarginController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'نسبة نقطة البيع', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.green)),
                          onPressed: () {
                            if (_catNameController.text.isNotEmpty && _catPriceController.text.isNotEmpty) {
                              setModalState(() {
                                categories.add(CategoryModel(
                                  name: _catNameController.text,
                                  price: double.tryParse(_catPriceController.text) ?? 0,
                                  margin: double.tryParse(_catMarginController.text) ?? 0,
                                  remaining: 0,
                                  sold: 0,
                                ));
                                _catNameController.clear();
                                _catPriceController.clear();
                                _catMarginController.clear();
                              });
                              setState(() {});
                            }
                          },
                          child: const Text('إضافه', style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('الفئات المضافة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    categories.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('لا توجد فئات مضافة بعد', style: TextStyle(color: Colors.grey)),
                          )
                        : Table(
                            border: TableBorder.all(color: Colors.grey.shade300),
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
                                children: [
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('الفئة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('السعر', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('النسبة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('تعديل', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('حذف', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              ...categories.map((cat) {
                                return TableRow(
                                  children: [
                                    Padding(padding: const EdgeInsets.all(6.0), child: Text(cat.name, textAlign: TextAlign.center)),
                                    Padding(padding: const EdgeInsets.all(6.0), child: Text('${cat.price.toInt()}', textAlign: TextAlign.center)),
                                    Padding(padding: const EdgeInsets.all(6.0), child: Text('${cat.margin.toInt()}', textAlign: TextAlign.center)),
                                    IconButton(icon: const Icon(Icons.edit, size: 16, color: Colors.blue), onPressed: () {}),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                      onPressed: () {
                                        setModalState(() {
                                          categories.remove(cat);
                                        });
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, minimumSize: const Size(double.infinity, 40)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق X', style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 4. نافذة التقرير وتتبع المتبقي والمباع ديناميكياً
  void _showReportAndAddCardsSheet(NetworkRequest net) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF3EDF7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'شبكة ${net.networkName} ( ${net.city} - ${net.phone} )',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    categories.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'لا توجد فئات مضافة لهذه الشبكة حتى الآن.\nقم باضافة الفئات أولاً من خيار "الفئات".',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // المتبقي (يُقرأ ديناميكياً)
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.lightBlue.shade300,
                                      child: Text('${cat.remaining}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('الباقي في', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 8),
                                    Text('فئة ${cat.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    const Text('تم بيع', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 6),
                                    // المباع (يُقرأ ديناميكياً)
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.orange.shade400,
                                      child: Text('${cat.sold}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const Spacer(),
                                    // زر إضافة كروت لهذه الفئة
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF5A3192),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                      onPressed: () {
                                        _showAddCardsDialog(cat, onAdded: (count) {
                                          setModalState(() {
                                            cat.remaining += count; // زيادة المتبقي تلقائياً بعد اللصق
                                          });
                                          setState(() {});
                                        });
                                      },
                                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                      label: const Text('اضافة', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق X', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 5. نافذة لصق الكروت
  void _showAddCardsDialog(CategoryModel cat, {Function(int count)? onAdded}) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'إضافة كروت فئة ${cat.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _cardsController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'اكتب او الصق ارقام الكروت هنا',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A3192)),
                onPressed: () {
                  if (_cardsController.text.isNotEmpty) {
                    // حساب عدد الأسطر المنسوخة
                    final lines = _cardsController.text.split('\n').where((l) => l.trim().isNotEmpty).length;
                    final addedCount = lines > 0 ? lines : 1;

                    if (onAdded != null) {
                      onAdded(addedCount);
                    } else {
                      setState(() {
                        cat.remaining += addedCount;
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تمت إضافة $addedCount كارت بنجاح بفئة ${cat.name}')),
                    );
                    _cardsController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text('اضافه', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}

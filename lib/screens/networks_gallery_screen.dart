import 'package:flutter/material.dart';
import '../models/network_request.dart';
import 'add_network_screen.dart';

class NetworksGalleryScreen extends StatefulWidget {
  const NetworksGalleryScreen({super.key});

  @override
  State<NetworksGalleryScreen> createState() => _NetworksGalleryScreenState();
}

class _NetworksGalleryScreenState extends State<NetworksGalleryScreen> {
  final _catNameController = TextEditingController();
  final _catPriceController = TextEditingController();
  final _catMarginController = TextEditingController();
  final _cardsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final approvedNetworks = NetworkDataStore.requests.where((r) => r.status == 'مقبول').toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معرض شبكاتي'),
          backgroundColor: const Color(0xFF5A3192),
          centerTitle: true,
        ),
        body: approvedNetworks.isEmpty
            ? _buildEmptyGalleryView(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: approvedNetworks.length,
                itemBuilder: (context, index) {
                  final net = approvedNetworks[index];
                  return _buildNetworkItem(net);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyGalleryView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لا توجد شبكات معتمدة حالياً', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('قم بإضافة شبكتك وانتظر موافقة الإدارة لتظهر هنا', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A3192)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNetworkScreen())).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('طلب إضافة شبكة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkItem(NetworkRequest net) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض اسم الشبكة، المنطقة، والهاتف المأخوذة ديناميكياً من النموذج
            Text('شبكة ${net.networkName} ( ${net.city} ) ${net.phone}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('رقم الشبكة: ${net.id}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionButton(Icons.card_giftcard, 'الكروت', () {
                  if (net.categories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد فئات مضافة بعد، يرجى الضغط على (الفئات) لإضافة فئة أولاً')));
                  } else {
                    _showAddCardsDialog(net, net.categories.first);
                  }
                }),
                _buildOptionButton(Icons.ac_unit, 'الفئات', () => _showCategoriesModal(net)),
                _buildOptionButton(Icons.warning_amber_rounded, 'تقرير + إضافة الكروت', () => _showReportModal(net)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFFFFDE7), border: Border.all(color: Colors.amber.shade300), borderRadius: BorderRadius.circular(8)),
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

  // نافذة إضافة وإدارة الفئات من قبل صاحب الشبكة
  void _showCategoriesModal(NetworkRequest net) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 16, right: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('إضافة فئة جديدة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _catNameController, decoration: const InputDecoration(labelText: 'الفئة *', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _catPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر *', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _catMarginController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'نسبة نقطة البيع', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () {
                            if (_catNameController.text.isNotEmpty && _catPriceController.text.isNotEmpty) {
                              setModalState(() {
                                net.categories.add(CategoryModel(
                                  name: _catNameController.text.trim(),
                                  price: double.tryParse(_catPriceController.text) ?? 0,
                                  margin: double.tryParse(_catMarginController.text) ?? 0,
                                ));
                                _catNameController.clear();
                                _catPriceController.clear();
                                _catMarginController.clear();
                              });
                              setState(() {}); // تحديث الشاشة الرئيسية
                            }
                          },
                          child: const Text('إضافة', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('الفئات المضافة حالياً', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    net.categories.isEmpty
                        ? const Padding(padding: EdgeInsets.all(12.0), child: Text('لم تقم بإضافة أي فئة بعد', style: TextStyle(color: Colors.grey)))
                        : Table(
                            border: TableBorder.all(color: Colors.grey.shade300),
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
                                children: [
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('الفئة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('السعر', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('النسبة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6.0), child: Text('حذف', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              ...net.categories.map((cat) {
                                return TableRow(
                                  children: [
                                    Padding(padding: const EdgeInsets.all(6.0), child: Text(cat.name, textAlign: TextAlign.center)),
                                    Padding(padding: const EdgeInsets.all(6.0), child: Text('${cat.price.toInt()}', textAlign: TextAlign.center)),
                                    Padding(padding: const EdgeInsets.all(6.0), child: Text('${cat.margin.toInt()}', textAlign: TextAlign.center)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                      onPressed: () {
                                        setModalState(() => net.categories.remove(cat));
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق X')),
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

  // نافذة تقرير الفئات المضافة + إضافة الكروت
  void _showReportModal(NetworkRequest net) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF3EDF7),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  net.categories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('لا توجد فئات مضافة بعد لمشاهدة التقرير وإضافة الكروت. يرجى إضافة الفئات أولاً.'),
                        )
                      : Column(
                          children: net.categories.map((cat) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 12, backgroundColor: Colors.lightBlue.shade300, child: Text('${cat.remaining}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                                  const SizedBox(width: 4),
                                  Text('الباقي في فئة ${cat.name}'),
                                  const SizedBox(width: 8),
                                  CircleAvatar(radius: 12, backgroundColor: Colors.orange.shade400, child: Text('${cat.sold}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                                  const SizedBox(width: 4),
                                  const Text('تم بيع'),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A3192)),
                                    onPressed: () {
                                      _showAddCardsDialog(net, cat, onAdded: (count) {
                                        setModalState(() => cat.remaining += count);
                                        setState(() {});
                                      });
                                    },
                                    icon: const Icon(Icons.add, size: 14, color: Colors.white),
                                    label: const Text('إضافة', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق X')),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCardsDialog(NetworkRequest net, CategoryModel cat, {Function(int count)? onAdded}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة كروت فئة ${cat.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          content: TextField(
            controller: _cardsController,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'اكتب أو الصق أرقام الكروت هنا', border: OutlineInputBorder()),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A3192)),
              onPressed: () {
                if (_cardsController.text.isNotEmpty) {
                  final count = _cardsController.text.split('\n').where((l) => l.trim().isNotEmpty).length;
                  final addedCount = count > 0 ? count : 1;
                  if (onAdded != null) {
                    onAdded(addedCount);
                  } else {
                    setState(() => cat.remaining += addedCount);
                  }
                  _cardsController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/network_request.dart';

class WifiCabinScreen extends StatefulWidget {
  const WifiCabinScreen({super.key});

  @override
  State<WifiCabinScreen> createState() => _WifiCabinScreenState();
}

class _WifiCabinScreenState extends State<WifiCabinScreen> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  final Set<String> _favoriteNetworkIds = {};

  @override
  Widget build(BuildContext context) {
    // جلب الشبكات المقبولة فقط
    final approvedNetworks = NetworkDataStore.requests.where((net) {
      final isApproved = net.status == 'مقبول';
      final matchesSearch = net.networkName.contains(_searchQuery) ||
          net.id.contains(_searchQuery) ||
          net.city.contains(_searchQuery);
      final matchesFavorite = !_showFavoritesOnly || _favoriteNetworkIds.contains(net.id);

      return isApproved && matchesSearch && matchesFavorite;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('كابينة WIFI'),
          backgroundColor: const Color(0xFF5A3192),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {}),
            ),
          ],
        ),
        body: Column(
          children: [
            // تبويب المفضلة / كل الشبكات + شريط البحث
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _showFavoritesOnly = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_showFavoritesOnly ? const Color(0xFF5A3192) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF5A3192)),
                            ),
                            child: Text(
                              'كل الشبكات',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_showFavoritesOnly ? Colors.white : const Color(0xFF5A3192),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _showFavoritesOnly = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _showFavoritesOnly ? const Color(0xFF5A3192) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF5A3192)),
                            ),
                            child: Text(
                              'المفضلة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _showFavoritesOnly ? Colors.white : const Color(0xFF5A3192),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'بحث باسم الشبكة او رقمها',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة الشبكات
            Expanded(
              child: approvedNetworks.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد شبكات متاحة حالياً',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: approvedNetworks.length,
                      itemBuilder: (context, index) {
                        final net = approvedNetworks[index];
                        final isFav = _favoriteNetworkIds.contains(net.id);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            onTap: () => _showBuyCardBottomSheet(net),
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade50,
                              child: Text(net.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A3192), fontSize: 12)),
                            ),
                            title: Text(
                              '${net.id} - ${net.networkName} (${net.city})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text('تلفون ${net.phone}', style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isFav) {
                                    _favoriteNetworkIds.remove(net.id);
                                  } else {
                                    _favoriteNetworkIds.add(net.id);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة الشراء واختيار الفئات ورقم الهاتف
  void _showBuyCardBottomSheet(NetworkRequest net) {
    final phoneController = TextEditingController();
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عنوان الشبكة ورقم الهاتف
                    Text(
                      'شبكة ${net.networkName} ( ${net.city} ) ${net.phone}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // إدخال رقم هاتف الزبون
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'رقم هاتف الزبون',
                        prefixIcon: const Icon(Icons.phone_android),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'سيتم ارسال رقم الكرت برسال نصيه للزبون.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // تحديد الكمية (+ / -)
                    const Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setModalState(() => quantity++);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(color: Color(0xFF5A3192), borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
                            child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                          child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        InkWell(
                          onTap: () {
                            if (quantity > 1) {
                              setModalState(() => quantity--);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(color: Color(0xFF5A3192), borderRadius: BorderRadius.horizontal(left: Radius.circular(8))),
                            child: const Text('-', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // عرض الفئات المضافة من قبل صاحب الشبكة
                    net.categories.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'لا توجد فئات مضافة لهذه الشبكة حالياً',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: net.categories.map((cat) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  _showConfirmOrderDialog(net, cat, quantity, phoneController.text.trim());
                                },
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.purple.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.wifi, size: 14, color: Color(0xFF5A3192)),
                                          const SizedBox(width: 4),
                                          Text('YER ${cat.price.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5A3192))),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
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

  // نافذة تأكيد الطلب وتقسيم المبالغ الخصم
  void _showConfirmOrderDialog(NetworkRequest net, CategoryModel cat, int quantity, String clientPhone) {
    final double totalCost = cat.price * quantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.amber,
                radius: 20,
                child: Icon(Icons.info_outline, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              const Text('تأكيد الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),

              _buildDetailRow('الخدمة', 'كروت شبكات WIFI'),
              _buildDetailRow('الشبكة', 'شبكة ${net.networkName} ( ${net.city} ) - ${net.phone}'),
              _buildDetailRow('الصنف', cat.name),
              _buildDetailRow('المبلغ', '${cat.price.toInt()}'),
              _buildDetailRow('النسبة', '% ${cat.margin.toInt()}'),
              _buildDetailRow('الكمية', '$quantity'),
              _buildDetailRow('التكلفة', '${totalCost.toInt()}'),
              const Divider(),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A3192)),
                      onPressed: () {
                        Navigator.pop(context);
                        _processPurchase(net, cat, quantity, clientPhone);
                      },
                      child: const Text('شراء', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                      onPressed: () {
                        Navigator.pop(context);
                        _sendViaSMS(clientPhone, net.networkName, cat.name);
                      },
                      child: const Text('عبرالرسائل', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        Navigator.pop(context);
                        _sendViaWhatsApp(clientPhone, net.networkName, cat.name);
                      },
                      child: const Text('عبرالواتس', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: Colors.grey.shade200,
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _processPurchase(NetworkRequest net, CategoryModel cat, int quantity, String phone) {
    if (cat.remaining >= quantity) {
      setState(() {
        cat.remaining -= quantity;
        cat.sold += quantity;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم شراء $quantity كرت من شبكة ${net.networkName} بنجاح، وتم الخصم من المحفظة.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عذراً، عدد الكروت المتوفرة غير كافٍ في هذه الفئة')),
      );
    }
  }

  void _sendViaSMS(String phone, String netName, String catName) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': 'تم شراء كرت شبكة $netName فئة $catName بنجاح.'});
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  void _sendViaWhatsApp(String phone, String netName, String catName) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent('تم شراء كرت شبكة $netName فئة $catName بنجاح.')}");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  final Map<String, dynamic> network;

  const CategoriesScreen({super.key, required this.network});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isBuying = false;

  void _handleBuy(int categoryId, String categoryName) async {
    setState(() => _isBuying = true);
    try {
      final cardData = await ApiService.buyCard(categoryId);
      if (!mounted) return;

      _showCardDialog(categoryName, cardData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  void _showCardDialog(String categoryName, Map<String, dynamic> cardData) {
    final cardCode = cardData['code'] ?? cardData['username'] ?? 'بدون كود';
    final password = cardData['password'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تم شراء الكرت بنجاح! 🎉', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الفئة: $categoryName', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  SelectableText('الكود / المستخدم: $cardCode', style: const TextStyle(fontSize: 16)),
                  if (password.isNotEmpty)
                    SelectableText('كلمة المرور: $password', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              final textToShare = 'كارت واي فاي (${widget.network['name']})\nالفئة: $categoryName\nالكود: $cardCode${password.isNotEmpty ? '\nكلمة المرور: $password' : ''}';
              Share.share(textToShare);
            },
            icon: const Icon(Icons.share),
            label: const Text('مشاركة'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.network['categories'] as List<dynamic>? ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('فئات ${widget.network['name'] ?? ''}'),
        ),
        body: categories.isEmpty
            ? const Center(child: Text('لا توجد فئات متاحة لهذه الشبكة'))
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(cat['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('السعر: ${cat['price']} ر.ي'),
                      trailing: ElevatedButton(
                        onPressed: _isBuying ? null : () => _handleBuy(cat['id'], cat['name'] ?? ''),
                        child: _isBuying
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('شراء كرت'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

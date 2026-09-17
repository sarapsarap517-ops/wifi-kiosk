import 'package:flutter/material.dart';
import '../services/network_service.dart';

class NetworksGalleryScreen extends StatefulWidget {
  const NetworksGalleryScreen({super.key});

  @override
  State<NetworksGalleryScreen> createState() => _NetworksGalleryScreenState();
}

class _NetworksGalleryScreenState extends State<NetworksGalleryScreen> {
  bool isApprovedOwner = false;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _networkNameController = TextEditingController();
  final _regionController = TextEditingController();

  void _submitNetworkRequest() {
    if (_networkNameController.text.isNotEmpty) {
      // إضافة الشبكة فوراً للقائمة الافتراضية
      NetworkService.addNetwork(
        networkName: _networkNameController.text,
        phone: _phoneController.text,
        region: _regionController.text,
      );

      _fullNameController.clear();
      _phoneController.clear();
      _networkNameController.clear();
      _regionController.clear();

      Navigator.pop(context); // إغلاق نموذج الطلب
      _showConfirmationMessage();
    }
  }

  void _showAddNetworkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أضف شبكتك مجاناً', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5A3192))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('الاسم الرباعي', _fullNameController),
              _buildDialogField('رقم الجوال', _phoneController, isPhone: true),
              _buildDialogField('اسم الشبكة', _networkNameController),
              _buildDialogField('المنطقة', _regionController),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A3192)),
            onPressed: _submitNetworkRequest,
            child: const Text('موافق'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          'سيتم مراجعة طلبك أقرب وقت ممكن',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تم'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معرض شبكاتي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isApprovedOwner ? _buildOwnerDashboard() : _buildNonOwnerView(),
    );
  }

  Widget _buildNonOwnerView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'معرض شبكاتي خاص بأصحاب الشبكات فقط',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك تقديم طلب للإدارة لإضافة شبكتك والحصول على الصلاحية.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A3192),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _showAddNetworkDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('أضف شبكتك مجاناً', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerDashboard() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildNetworkCard('200', sold: 67, remaining: 83),
        _buildNetworkCard('500', sold: 54, remaining: 93),
        _buildNetworkCard('1000', sold: 16, remaining: 38),
      ],
    );
  }

  Widget _buildNetworkCard(String price, {required int sold, required int remaining}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text('فئة $price'),
        subtitle: Text('تم بيع: $sold | الباقي: $remaining'),
        trailing: const Icon(Icons.add),
      ),
    );
  }
}

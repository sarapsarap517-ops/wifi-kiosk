import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/network_request.dart';

class AddNetworkScreen extends StatefulWidget {
  const AddNetworkScreen({super.key});

  @override
  State<AddNetworkScreen> createState() => _AddNetworkScreenState();
}

class _AddNetworkScreenState extends State<AddNetworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _networkNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  // رقم الواتساب الخاص بالإدارة
  final String _adminWhatsAppPhone = "967730728514";

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. إضافة الطلب إلى قائمة الطلبات
    final newRequest = NetworkRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      networkName: _networkNameController.text,
      ownerName: _ownerNameController.text,
      phone: _phoneController.text,
      city: _cityController.text,
      status: 'معلق',
    );

    setState(() {
      NetworkDataStore.requests.add(newRequest);
    });

    // 2. تجهيز وفتح الواتساب
    final String message = '''
طلب إضافة شبكة جديدة 📡
-------------------------
اسم الشبكة: ${_networkNameController.text}
اسم المالك: ${_ownerNameController.text}
رقم التواصل: ${_phoneController.text}
المدينة / المنطقة: ${_cityController.text}
-------------------------
يرجى المراجعة والقبول من لوحة التحكم.
''';

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$_adminWhatsAppPhone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تقديم الطلب وتم فتح الواتساب للإرسال للإدارة')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلب إضافة شبكة'),
          backgroundColor: const Color(0xFF5A3192),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _networkNameController,
                  decoration: const InputDecoration(labelText: 'اسم الشبكة', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(labelText: 'اسم المالك / المسؤول', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'المدينة / العنوان', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A3192),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitRequest,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text('إرسال الطلب عبر الواتساب وللإدارة', style: TextStyle(color: Colors.white, fontSize: 16)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

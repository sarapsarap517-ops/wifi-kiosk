import 'package:flutter/material.dart';

import '../models/network_request.dart';

class AddNetworkScreen extends StatefulWidget {
  const AddNetworkScreen({super.key});

  @override
  State<AddNetworkScreen> createState() => _AddNetworkScreenState();
}

class _AddNetworkScreenState extends State<AddNetworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _netNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final generatedId =
          (1000 + NetworkDataStore.requests.length + 1).toString();

      final newNetwork = NetworkRequest(
        id: generatedId,
        networkName: _netNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        status: 'قيد الانتظار',
        categories: const [],
      );

      setState(() {
        NetworkDataStore.requests.add(newNetwork);
      });

      await NetworkDataStore.saveData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إرسال طلب إضافة شبكة "${newNetwork.networkName}" بنجاح، بانتظار موافقة الأدمن.',
          ),
        ),
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
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _netNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الشبكة *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'يرجى إدخال اسم الشبكة' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المالك *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'يرجى إدخال اسم المالك' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'المدينة / المنطقة *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'يرجى إدخال المدينة' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A3192),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitRequest,
                  child: const Text(
                    'إرسال الطلب',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

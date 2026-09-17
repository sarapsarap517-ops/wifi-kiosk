import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _fingerprintEnabled = true;
  bool _pinEnabled = false;
  bool _notifyLowBalance = true;
  String _selectedAddress = 'عنوان 2';

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text('اختر العنوان', style: TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAddressOption('عنوان 1'),
            const SizedBox(height: 10),
            _buildAddressOption('عنوان 2'),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressOption(String address) {
    bool isSelected = _selectedAddress == address;
    return InkWell(
      onTap: () {
        setState(() => _selectedAddress = address);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
          border: Border.all(color: isSelected ? Colors.green : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_outlined, color: isSelected ? Colors.green : Colors.blue),
                const SizedBox(width: 10),
                Text(address, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F3F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
          ],
          title: const Text('الإعدادات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('إعدادات الدخول'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: const Color(0xFF5A3192),
                    title: const Text('تفعيل البصمة للدخول للحساب'),
                    secondary: const Icon(Icons.fingerprint),
                    value: _fingerprintEnabled,
                    onChanged: (val) => setState(() => _fingerprintEnabled = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeColor: const Color(0xFF5A3192),
                    title: const Text('تفعيل الرمز السري'),
                    secondary: const Icon(Icons.lock_reset),
                    value: _pinEnabled,
                    onChanged: (val) => setState(() => _pinEnabled = val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('تغيير الرمز السري'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            _buildSectionHeader('تأكيد الأجهزة'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.smartphone), title: const Text('ترخيص هذا الجهاز'), onTap: () {}),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.add_to_home_screen), title: const Text('ترخيص جهاز جديد'), onTap: () {}),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.qr_code_scanner), title: const Text('ترخيص جهاز الويب (التقاط الباركد)'), onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 15),

            _buildSectionHeader('إعدادات اخرى'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: const Color(0xFF5A3192),
                    title: Row(
                      children: [
                        const Text('اشعاري عندما يكون رصيدي '),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: const Text('5000', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    secondary: const Icon(Icons.notifications_none),
                    value: _notifyLowBalance,
                    onChanged: (val) => setState(() => _notifyLowBalance = val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.android, color: Colors.green),
                    title: const Text('اصدار التطبيق: 939'),
                    trailing: TextButton(onPressed: () {}, child: const Text('تحديث التطبيق', style: TextStyle(color: Color(0xFF5A3192)))),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_outlined),
                    title: const Text('تغيير العنوان'),
                    onTap: _showAddressDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('تسجيل خروج', style: TextStyle(color: Colors.red)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Color(0xFF5A3192), fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

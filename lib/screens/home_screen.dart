import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';
import 'add_network_screen.dart';
import 'networks_gallery_screen.dart';
import 'admin_requests_screen.dart';
import 'wifi_cabin_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // دالة فتح الواتساب للدعم الفني
  Future<void> _openWhatsApp(BuildContext context) async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/967730728514");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح تطبيق الواتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الرئيسية'),
          backgroundColor: const Color(0xFF5A3192),
          centerTitle: true,
        ),
        drawer: _buildDrawer(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildHomeCard(
                context,
                title: 'كابينة WiFi',
                icon: Icons.wifi,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WifiCabinScreen()),
                  );
                },
              ),
              _buildHomeCard(
                context,
                title: 'معرض شبكاتي',
                icon: Icons.cell_tower,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NetworksGalleryScreen()),
                  );
                },
              ),
              _buildHomeCard(
                context,
                title: 'طلب إضافة شبكة',
                icon: Icons.add_business,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddNetworkScreen()),
                  );
                },
              ),
              _buildHomeCard(
                context,
                title: 'الدعم الفني',
                icon: Icons.support_agent,
                color: Colors.orange,
                onTap: () => _openWhatsApp(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF5A3192)),
            accountName: Text('عزيزي العميل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text('مرحباً بك في التطبيق', style: TextStyle(color: Colors.white70)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF5A3192)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF5A3192)),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Color(0xFF5A3192)),
            title: const Text('طلب إضافة شبكة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNetworkScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.wifi, color: Color(0xFF5A3192)),
            title: const Text('معرض شبكاتي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NetworksGalleryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF5A3192)),
            title: const Text('طلبات الشبكات (الأدمن)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRequestsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('تسجيل خروج', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

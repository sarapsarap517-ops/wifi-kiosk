import 'package:flutter/material.dart';
import 'wifi_cabin_screen.dart';
import 'networks_gallery_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر البنفسجي للرصيد والحساب
              Container(
                color: const Color(0xFF5A3192),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Stack(
                          children: [
                            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(
                          backgroundColor: Colors.lightBlueAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('الرصيد المتاح', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 5),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('*****', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.visibility_off, color: Colors.white70, size: 18),
                      ],
                    ),
                  ],
                ),
              ),

              // شبكة الخدمات الأساسية
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildServiceItem(
                      context,
                      Icons.payment,
                      'كبينة السداد',
                      Colors.orange,
                      onTap: () {},
                    ),
                    _buildServiceItem(
                      context,
                      Icons.wifi,
                      'كبينة WIFI',
                      Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WifiCabinScreen()),
                        );
                      },
                    ),
                    _buildServiceItem(context, Icons.apps, 'البرامج', Colors.green, onTap: () {}),
                    _buildServiceItem(context, Icons.sports_esports, 'معرض الألعاب', Colors.cyan, onTap: () {}),
                    _buildServiceItem(context, Icons.add_card, 'غذى حسابك', Colors.blue, onTap: () {}),
                    _buildServiceItem(context, Icons.people_alt, 'إدارة العملاء', Colors.amber, onTap: () {}),
                    _buildServiceItem(context, Icons.menu_book, 'الدفتر المحاسبي', Colors.purple, onTap: () {}),
                    _buildServiceItem(context, Icons.headset_mic, 'الدعم الفني', Colors.grey, onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF5A3192),
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'الخدمات'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'المزيد'),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, IconData icon, String title, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ],
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
            accountName: Text('عزيزي العميل'),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF5A3192)),
            ),
          ),
          _buildDrawerTile(Icons.settings, 'الإعدادات'),
          _buildDrawerTile(Icons.list_alt, 'العمليات'),
          _buildDrawerTile(Icons.bar_chart, 'التقارير'),
          _buildDrawerTile(Icons.wallet, 'التأمينات'),
          _buildDrawerTile(Icons.today, 'اليوميات'),
          _buildDrawerTile(Icons.emoji_events, 'المسابقات'),
          _buildDrawerTile(Icons.campaign, 'عروض وإعلانات'),
          _buildDrawerTile(Icons.sim_card, 'الشرائح'),
          _buildDrawerTile(
            Icons.wifi_tethering,
            'معرض شبكاتي',
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة الجانبية
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NetworksGalleryScreen()),
              );
            },
          ),
          const Divider(),
          _buildDrawerTile(
            Icons.logout,
            'تسجيل خروج',
            color: Colors.red,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String title, {VoidCallback? onTap, Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}

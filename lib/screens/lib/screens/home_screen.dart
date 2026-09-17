import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _networks = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNetworks();
  }

  Future<void> _fetchNetworks() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getNetworks(search: _searchQuery);
      setState(() => _networks = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الشبكات المتاحة'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: (val) {
                  _searchQuery = val;
                  _fetchNetworks();
                },
                decoration: const InputDecoration(
                  labelText: 'بحث عن شبكة أو رقم هاتف',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _networks.isEmpty
                      ? const Center(child: Text('لا توجد شبكات متاحة'))
                      : ListView.builder(
                          itemCount: _networks.length,
                          itemBuilder: (context, index) {
                            final net = _networks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.wifi, color: Colors.blue),
                                title: Text(net['name'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text('رقم الشبكة: ${net['number']}'),
                                trailing: const Icon(Icons.chevron_left),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoriesScreen(network: net),
                                    ),
                                  );
                                },
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
}

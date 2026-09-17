import 'package:flutter/material.dart';
import '../services/network_service.dart';

class WifiCabinScreen extends StatefulWidget {
  const WifiCabinScreen({super.key});

  @override
  State<WifiCabinScreen> createState() => _WifiCabinScreenState();
}

class _WifiCabinScreenState extends State<WifiCabinScreen> {
  int _selectedTab = 0; // 0: كل الشبكات, 1: المفضلة
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // تصفية الشبكات بناءً على البحث والتبويب
    final filteredNetworks = NetworkService.defaultNetworks.where((net) {
      bool matchesSearch = net.name.contains(_searchQuery) || net.info.contains(_searchQuery) || net.id.contains(_searchQuery);
      if (_selectedTab == 1) {
        return matchesSearch && net.isFavorite;
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('كبينة WIFI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton('المفضلة', 1),
              _buildTabButton('كل الشبكات', 0),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              textAlign: TextAlign.right,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث بإسم الشبكة او رقمها',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredNetworks.length,
              itemBuilder: (context, index) {
                final net = filteredNetworks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            net.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: net.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              net.isFavorite = !net.isFavorite;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(net.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5A3192))),
                              const SizedBox(height: 4),
                              Text(net.info, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(net.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A3192))),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5A3192) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF5A3192)),
        ),
        child: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF5A3192), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/network_request.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات إنضمام الشبكات'),
          backgroundColor: const Color(0xFF00897B),
          centerTitle: true,
        ),
        body: NetworkDataStore.requests.isEmpty
            ? const Center(child: Text('لا توجد طلبات انضمام حالياً'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: NetworkDataStore.requests.length,
                itemBuilder: (context, index) {
                  final req = NetworkDataStore.requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('اسم الشبكة: ${req.networkName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
                          const SizedBox(height: 6),
                          Text('اسم المالك: ${req.ownerName}'),
                          Text('رقم الهاتف: ${req.phone}'),
                          Text('المدينة: ${req.city}'),
                          Text('رقم التسلسلي (رقم الشبكة): ${req.id}', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: req.status == 'مقبول' ? Colors.green : (req.status == 'مرفوض' ? Colors.red : Colors.orange),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('الحالة: ${req.status}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const Spacer(),
                              if (req.status != 'مقبول')
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      req.status = 'مقبول';
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم قبول شبكة "${req.networkName}" بنجاح!')));
                                  },
                                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                  label: const Text('قبول', style: TextStyle(color: Colors.white)),
                                ),
                              const SizedBox(width: 8),
                              if (req.status != 'مرفوض')
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      req.status = 'مرفوض';
                                    });
                                  },
                                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                  label: const Text('رفض', style: TextStyle(color: Colors.white)),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

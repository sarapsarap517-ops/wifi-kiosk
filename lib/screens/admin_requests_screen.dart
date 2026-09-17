import 'package:flutter/material.dart';
import '../models/network_request.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final requests = NetworkDataStore.requests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات إنضمام الشبكات'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: requests.isEmpty
          ? const Center(
              child: Text(
                'لا توجد طلبات معلقة حالياً',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اسم الشبكة: ${req.networkName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const Divider(),
                        Text('اسم المالك: ${req.ownerName}'),
                        Text('رقم الهاتف: ${req.phone}'),
                        Text('المدينة: ${req.city}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('الحالة: '),
                            Chip(
                              label: Text(
                                req.status,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: req.status == 'مقبول'
                                  ? Colors.green
                                  : req.status == 'مرفوض'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  req.status = 'مقبول';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم قبول الطلب')),
                                );
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('قبول'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  req.status = 'مرفوض';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم رفض الطلب')),
                                );
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('رفض'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

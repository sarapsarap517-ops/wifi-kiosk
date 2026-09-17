import 'package:flutter/material.dart';
import 'categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('كروت الواي فاي'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(
                        network: {'name': 'الشبكة الرئيسية', 'id': '1'},
                      ),
                    ),
                  );
                },
                child: const Text('عرض الشبكات والفئات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

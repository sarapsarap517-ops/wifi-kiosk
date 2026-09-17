import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F3F8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // الشعار العلوي
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi, size: 60, color: Color(0xFF5A3192)),
                ),
                const SizedBox(height: 30),

                // بطاقة بيانات الدخول
                Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const TextField(
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'اسم الدخول - رقم الهاتف',
                            suffixIcon: Icon(Icons.person_outline, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(height: 1),
                        TextField(
                          obscureText: !_isPasswordVisible,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'كلمة السر',
                            suffixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            prefixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // نسيت كلمة السر
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'نسيت كلمة السر؟',
                      style: TextStyle(color: Color(0xFF5A3192), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // زر الدخول
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A3192),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      'دخول',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // أيقونة البصمة
                const Icon(Icons.fingerprint, size: 55, color: Color(0xFF5A3192)),
                const SizedBox(height: 25),

                // خيار إنشاء حساب
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لايوجد لديك حساب ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(color: Color(0xFF5A3192), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // أزرار التواصل والدعم بالأسفل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBottomIconButton(Icons.phone, Colors.blue),
                    const SizedBox(width: 15),
                    _buildBottomIconButton(Icons.code, Colors.red),
                    const SizedBox(width: 15),
                    _buildBottomIconButton(Icons.info_outline, Colors.lightBlue),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIconButton(IconData icon, Color color) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

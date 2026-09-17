import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessController = TextEditingController();
  final _addressController = TextEditingController();
  final _distributorController = TextEditingController();

  String _selectedDocType = 'بطاقة شخصية';
  bool _agreedToTerms = false;
  bool _hasDocumentImage = false; // حالة إرفاق صورة الوثيقة

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
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5A3192)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'إنشاء حساب',
            style: TextStyle(color: Color(0xFF5A3192), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان البيانات الشخصية
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'البيانات الشخصية',
                        style: TextStyle(color: Color(0xFF5A3192), fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 15),

                // حقول البيانات مع الرسائل التحذيرية الحمراء
                _buildInputField(
                  controller: _nameController,
                  hint: 'الاسم الرباعي مع اللقب',
                  icon: Icons.person_outline,
                  errorMsg: 'يرجى ادخال الاسم الرباعي مع اللقب',
                ),
                _buildInputField(
                  controller: _phoneController,
                  hint: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  isPhone: true,
                  errorMsg: 'يرجى ادخال رقم الهاتف',
                ),
                _buildInputField(
                  controller: _businessController,
                  hint: 'النشاط التجاري',
                  icon: Icons.storefront_outlined,
                  errorMsg: 'يرجى ادخال النشاط التجاري',
                ),
                _buildInputField(
                  controller: _addressController,
                  hint: 'العنوان',
                  icon: Icons.location_on_outline,
                  errorMsg: 'يرجى ادخال العنوان',
                ),
                _buildInputField(
                  controller: _distributorController,
                  hint: 'رقم حساب الموزع (اختياري)',
                  icon: Icons.smartphone_outlined,
                  isRequired: false,
                ),

                const SizedBox(height: 10),
                const Text('اختر نوع الوثيقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),

                // خيارات الوثيقة
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDocRadio('بطاقة شخصية'),
                      _buildDocRadio('جواز سفر'),
                      _buildDocRadio('بطاقة عائلية'),
                      _buildDocRadio('سجل تجاري'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // خيار إرفاق صورة الهوية / الوثيقة
                InkWell(
                  onTap: () {
                    setState(() {
                      _hasDocumentImage = !_hasDocumentImage;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hasDocumentImage ? Colors.green.shade50 : Colors.white,
                      border: Border.all(color: _hasDocumentImage ? Colors.green : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasDocumentImage ? Icons.check_circle : Icons.camera_alt_outlined,
                          color: _hasDocumentImage ? Colors.green : const Color(0xFF5A3192),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasDocumentImage ? 'تم إرفاق صورة الوثيقة' : 'إرفاق صورة الوثيقة / الهوية',
                          style: TextStyle(
                            color: _hasDocumentImage ? Colors.green : const Color(0xFF5A3192),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // خيار الموافقة على الشروط
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: const Color(0xFF5A3192),
                      onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                    ),
                    const Text('قرأت وموافق على الشروط '),
                    const Text('وسياسة الخصوصية', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                  ],
                ),
                const SizedBox(height: 20),

                // زر إكمال التسجيل
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A3192),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _agreedToTerms
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم تقديم طلب إنشاء الحساب بنجاح')),
                              );
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    child: const Text('إكمال التسجيل', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isRequired = true,
    bool isPhone = false,
    String? errorMsg,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: isRequired
            ? (val) {
                if (val == null || val.trim().isEmpty) {
                  return errorMsg;
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: Icon(icon, color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildDocRadio(String title) {
    return Row(
      children: [
        Radio<String>(
          value: title,
          groupValue: _selectedDocType,
          activeColor: const Color(0xFF5A3192),
          onChanged: (val) => setState(() => _selectedDocType = val!),
        ),
        Text(title, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}


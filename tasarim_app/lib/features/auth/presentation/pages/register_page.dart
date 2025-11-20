import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  static const Color narposOrange = Color(0xFFF57C00);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.register}';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
          'roleId': 3, // Default role ID
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Başarılı kayıt - login sayfasına yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Şimdi giriş yapabilirsiniz.'),
            backgroundColor: narposOrange,
          ),
        );
        Navigator.pop(context); // Login sayfasına geri dön
      } else {
        // Hata durumu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bağlantı hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Alanı
                  SizedBox(
                    height: 120.0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/narposloginlogo.png',
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            '[ Logo Alanı ]',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Ad Soyad Alanı
                  _buildTextField(
                    controller: _nameController,
                    label: 'Ad Soyad',
                    hint: 'Ad Soyad',
                  ),
                  const SizedBox(height: 20.0),

                  // E-posta Alanı
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    hint: 'E-posta',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20.0),

                  // Telefon Numarası Alanı
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefon Numarası',
                    hint: 'Telefon Numarası',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20.0),

                  // Şifre Alanı
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Şifre',
                    hint: 'Şifre',
                    isObscure: true,
                  ),
                  const SizedBox(height: 20.0),

                  // Şifre Tekrar Alanı
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Şifre Tekrar',
                    hint: 'Şifre Tekrar',
                    isObscure: true,
                    isConfirmPassword: true,
                  ),
                  const SizedBox(height: 24.0),

                  // Kaydol Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: narposOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Kaydol',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32.0),

                  // Zaten hesabınız var mı?
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16.0,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Zaten hesabınız var mı? '),
                          TextSpan(
                            text: 'giriş yap.',
                            style: const TextStyle(
                              color: narposOrange,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isObscure = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: narposOrange, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label alanı boş bırakılamaz';
            }
            if (label == 'E-posta' && !value.contains('@')) {
              return 'Geçerli bir e-posta adresi girin';
            }
            if (label == 'Telefon Numarası') {
              final phoneRegex = RegExp(r'^[0-9]{10,11}$');
              if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                return 'Geçerli bir telefon numarası girin (10-11 rakam)';
              }
            }
            if (label == 'Şifre' && value.length < 6) {
              return 'Şifre en az 6 karakter olmalıdır';
            }
            if (isConfirmPassword && value != _passwordController.text) {
              return 'Şifreler eşleşmiyor';
            }
            return null;
          },
        ),
      ],
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../config/routes/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Form durumunu takip etmek için bir anahtar
  final _formKey = GlobalKey<FormState>();

  // Text alanlarını yönetmek için controller'lar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Ana renk (Narpos turuncusu)
  static const Color narposOrange = Color(0xFFF57C00); // Veya Colors.deepOrange

  @override
  void dispose() {
    // Controller'ları temizlemeyi unutmayın
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.login}';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Başarılı giriş - token'ı kaydet
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(StorageConstants.accessToken, responseData['accessToken']);
        await prefs.setString(StorageConstants.refreshToken, responseData['refreshToken']);
        await prefs.setString(StorageConstants.userEmail, responseData['email']);
        await prefs.setString(StorageConstants.userName, responseData['username']);
        await prefs.setString(StorageConstants.userRole, responseData['role']);
        if (responseData['phone'] != null) {
          await prefs.setString(StorageConstants.userPhone, responseData['phone']);
        }
        await prefs.setBool(StorageConstants.isLoggedIn, true);

        Navigator.pushReplacementNamed(context, AppRouter.home);
      } else {
        // Hata durumu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarısız: ${response.body}'),
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
        // Klavye açıldığında ekranın taşmasını önlemek için
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Logo Alanı
                  SizedBox(
                    height: 120.0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/narposloginlogo.png',
                        height: 100,
                        fit: BoxFit.contain,
                        // Eğer logo yoksa hata yerine fallback göster:
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
                  const SizedBox(height: 48.0),

                  // 2. E-posta Alanı
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    hint: 'E-posta',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20.0),

                  // 3. Şifre Alanı
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Şifre',
                    hint: 'Şifre',
                    isObscure: true,
                  ),
                  const SizedBox(height: 16.0),

                  // 4. Şifrenizi mi unuttunuz?
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Şifrenizi mi unuttunuz?',
                        style: TextStyle(
                          color: narposOrange,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // 5. Giriş Yap Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                            'Giriş Yap',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 48.0),

                  // 6. Hesabınız yok mu?
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
                          const TextSpan(text: 'Hesabınız yok mu? '),
                          TextSpan(
                            text: 'hemen kaydol.',
                            style: const TextStyle(
                              color: narposOrange,
                              fontWeight: FontWeight.bold,
                            ),
                            // Tıklanma olayı için
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
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

  /// Tekrar eden E-posta ve Şifre alanları için yardımcı bir metot.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isObscure = false,
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
            color: Colors.black.withOpacity(0.8),
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
            // Normal kenarlık
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            // Odaklanılmış kenarlık
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: narposOrange, width: 2.0),
            ),
            // Hata kenarlığı
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
          // Basit bir boş olamaz validasyonu
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label alanı boş bırakılamaz';
            }
            if (label == 'E-posta' && !value.contains('@')) {
              return 'Geçerli bir e-posta adresi girin';
            }
            return null;
          },
        ),
      ],
    );
  }
}

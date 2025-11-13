import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/storage_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NarSMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1)); // Splash screen için kısa bekleme

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(StorageConstants.isLoggedIn) ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      // Token varsa direkt home'a git
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      // Token yoksa login'e git
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

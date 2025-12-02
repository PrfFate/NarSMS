import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // TODO: Backend hazır olunca açılacak
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
// import 'core/constants/storage_constants.dart'; // TODO: Backend hazır olunca açılacak

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
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

class SplashScreen extends StatefulWidget
{
  const SplashScreen({super.key});

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
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // TODO: Geçici olarak direkt home'a yönlendiriyoruz
    // Token kontrolü yap
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString(StorageConstants.accessToken);

    // Token varsa home'a, yoksa login'e git
    // if (token != null && token.isNotEmpty) {
    //   Navigator.pushReplacementNamed(context, AppRouter.home);
    // } else {
    //   Navigator.pushReplacementNamed(context, AppRouter.login);
    // }

    // Geçici: Backend olmadığı için direkt home'a git
    Navigator.pushReplacementNamed(context, AppRouter.home);
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

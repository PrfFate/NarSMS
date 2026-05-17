import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/network/navigator_key.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

/// Uygulama giriş noktası.
///
/// Sorumlulukları:
/// 1. Çevre değişkenlerini (.env) yüklemek
/// 2. Dependency injection'ı başlatmak
/// 3. Flutter uygulamasını çalıştırmak
///
/// Routing ve oturum kontrolü [AppRouter] ve [SplashPage] tarafından yönetilir.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDependencies();
  runApp(
    BlocProvider<AuthBloc>(
      create: (context) => getIt<AuthBloc>(),
      child: const NarSmsApp(),
    ),
  );
}

class NarSmsApp extends StatelessWidget {
  const NarSmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NarSMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashPage(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

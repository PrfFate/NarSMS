import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: const LoginPage(),
          ),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<HomeBloc>(),
            child: const HomePage(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('404 - Page Not Found'),
            ),
          ),
        );
    }
  }
}

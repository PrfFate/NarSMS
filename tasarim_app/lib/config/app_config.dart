class AppConfig {
  static const String appName = 'Tasarim App';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = true;

  // API Configuration
  static const String apiBaseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCrashReporting = false;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  final String? Function() getAccessToken;

  ApiInterceptor({required this.getAccessToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

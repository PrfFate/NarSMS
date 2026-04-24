import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Tüm RemoteDataSource sınıflarının kullandığı merkezi Dio hata yönetimi.
///
/// Bu mixin'i `with ApiErrorHandler` şeklinde datasource implementasyonlarına
/// ekleyerek her sınıfta tekrarlanan [DioException] switch-case bloklarını
/// ortadan kaldırır (DRY prensibi).
///
/// Kullanım:
/// ```dart
/// class MyDataSourceImpl with ApiErrorHandler implements MyDataSource {
///   Future<Foo> getFoo() async {
///     try {
///       final res = await dio.get('/foo');
///       ...
///     } on DioException catch (e) {
///       handleDioException(e);   // <-- tek satır
///     }
///   }
/// }
/// ```
mixin ApiErrorHandler {
  /// [DioException]'ı uygun uygulama istisnasına dönüştürür ve fırlatır.
  ///
  /// Bu metot her zaman bir istisna fırlatır; dönüş tipi [Never]'dır.
  /// Böylece `return handleDioException(e)` şeklinde de kullanılabilir.
  Never handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;

    switch (statusCode) {
      case 400:
        // Bad Request - Detaylı hata mesajını ayıkla
        String errorMessage = 'Geçersiz istek';
        final responseData = e.response?.data;
        
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? responseData['error'] ?? responseData['title'] ?? responseData['detail'] ?? 'Geçersiz istek parametreleri';
          
          // Eğer ASP.NET Core Validation errors varsa
          if (responseData['errors'] != null && responseData['errors'] is Map) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        throw ServerException(
          message: errorMessage,
          statusCode: 400,
        );

      case 401:
        throw UnauthorizedException(
          message: 'Oturum süresi doldu veya yetki yok',
        );

      case 404:
        throw ServerException(
          message: 'Kayıt bulunamadı',
          statusCode: 404,
        );

      case 409:
        throw ServerException(
          message: 'Bu kayıt zaten mevcut',
          statusCode: 409,
        );

      case 422:
        // Backend doğrulama hatası — hata detayları varsa ilet
        final rawErrors = e.response?.data?['errors'];
        final Map<String, List<String>>? errors =
            rawErrors is Map<String, dynamic>
                ? rawErrors.map(
                    (key, value) => MapEntry(
                      key,
                      (value as List<dynamic>)
                          .map((v) => v.toString())
                          .toList(),
                    ),
                  )
                : null;

        throw ValidationException(
          message: 'Giriş doğrulama hatası',
          errors: errors,
        );

      default:
        // Dio'nun genel message'ı yerine API'nin döndüğü anlamlı hatayı (eğer varsa) bas.
        String defaultMsg = 'Beklenmeyen bir ağ hatası oluştu';
        if(e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null) {
          defaultMsg = e.response?.data['message'];
        }

        throw ServerException(
          message: defaultMsg,
          statusCode: statusCode,
        );
    }
  }
}

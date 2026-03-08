/// Uygulama genelinde kullanılan hata kodları.
///
/// Data ve Domain katmanı bu enum'u kullanarak UI-bağımsız
/// hata bilgisi taşır. Çeviri (Türkçe/İngilizce metin) yalnızca
/// Presentation katmanında yapılır.
enum AppFailureCode {
  /// Cihazın internete bağlı olmadığı durum.
  noInternet,

  /// Geçersiz kimlik bilgileri veya token süresi dolmuş.
  unauthorized,

  /// İstenen kaynak sunucuda bulunamadı (404).
  notFound,

  /// Girdi doğrulama hatası (422 Unprocessable Entity).
  validation,

  /// Kayıt çakışması (409 Conflict).
  conflict,

  /// Genel sunucu hatası (5xx veya bilinmeyen 4xx).
  serverError,

  /// Hiçbir kategoriye girmeyen beklenmeyen istemci hatası.
  unexpected,

  /// Önbellek (SharedPreferences vb.) okuma/yazma hatası.
  cacheError,
}

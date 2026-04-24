import 'package:dartz/dartz.dart';
import '../errors/exceptions.dart';
import '../errors/failure_codes.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';

/// Tüm repository implementasyonları için ortak temel sınıf.
///
/// Her repository metodunda tekrarlanan şu kalıbı tek yere toplar:
/// 1. İnternet bağlantısı kontrolü
/// 2. DataSource çağrısı — try/catch
/// 3. Exception → Failure dönüşümü
///
/// Kullanım:
/// ```dart
/// class MyRepositoryImpl extends BaseRepository implements MyRepository {
///   MyRepositoryImpl({required super.networkInfo});
///
///   @override
///   Future<Either<Failure, Foo>> getFoo(int id) {
///     return runNetworkCall(() => remoteDataSource.getFoo(id));
///   }
/// }
/// ```
abstract class BaseRepository {
  final NetworkInfo networkInfo;

  const BaseRepository({required this.networkInfo});

  /// İnternet kontrolü yapar, [call]'ı çalıştırır ve sonucu [Either]'a sarar.
  ///
  /// Başarıda: `Right(T)` döner.
  /// Bağlantı yoksa: `Left(NetworkFailure)` döner.
  /// Exception'da: uygun [Failure] alt tipine dönüştürür.
  Future<Either<Failure, T>> runNetworkCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      final hasConnection = await networkInfo.isConnected;
      if (!hasConnection) {
        return Left(
          NetworkFailure(
            'İnternet bağlantısı bulunamadı',
            code: AppFailureCode.noInternet,
          ),
        );
      }

      final result = await call();
      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(
        UnauthorizedFailure(e.message, code: AppFailureCode.unauthorized),
      );
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(
          e.message,
          code: AppFailureCode.validation,
          errors: e.errors,
        ),
      );
    } on ServerException catch (e) {
      final code = e.statusCode == 404
          ? AppFailureCode.notFound
          : e.statusCode == 409
              ? AppFailureCode.conflict
              : AppFailureCode.serverError;

      return Left(ServerFailure(e.message, code: code));
    } catch (e) {
      return Left(
        ServerFailure(
          'Beklenmeyen hata: ${e.toString()}',
          code: AppFailureCode.unexpected,
        ),
      );
    }
  }
}

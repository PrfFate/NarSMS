import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../realtime/role_change_hub_service.dart';

// Feature modülleri
import '../../features/auth/di/auth_injection.dart';
import '../../features/customers/di/customer_injection.dart';
import '../../features/devices/di/device_injection.dart';
import '../../features/home/di/home_injection.dart';
import '../../features/sales/di/sale_injection.dart';
import '../../features/technical_service/di/technical_service_injection.dart';
import '../../features/field_tasks/di/field_tasks_injection.dart';
import '../../features/field_management/di/field_management_injection.dart';

/// GetIt servis bulucu örneği — uygulama genelinde tek instance.
final getIt = GetIt.instance;

/// Uygulama başlatılırken çağrılan ana DI kurulum fonksiyonu.
///
/// Bu fonksiyon yalnızca external ve core bağımlılıkları kaydeder,
/// feature'a özel bağımlılıklar kendi modül dosyalarında yönetilir:
/// - [initAuthModule]      → `features/auth/di/auth_injection.dart`
/// - [initCustomerModule]  → `features/customers/di/customer_injection.dart`
/// - [initDeviceModule]    → `features/devices/di/device_injection.dart`
/// - [initHomeModule]      → `features/home/di/home_injection.dart`
///
/// Yeni bir feature eklendiğinde sadece yeni bir modül fonksiyonu
/// oluşturun ve buraya tek satır `await initXModule()` ekleyin.
Future<void> initializeDependencies() async {
  // ===== EXTERNAL DEPENDENCIES =====
  getIt.registerLazySingleton(() => Connectivity());

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // ===== CORE DEPENDENCIES =====
  getIt.registerLazySingleton(() => DioClient());
  getIt.registerLazySingleton(
    () => RoleChangeHubService(
      dioClient: getIt<DioClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // ===== FEATURE MODULES =====
  // Sıralama önemli: Home, Auth'a bağımlı olduğundan son sıradadır.
  await initAuthModule();
  await initCustomerModule();
  await initDeviceModule();
  await initSaleModule();
  await initTechnicalServiceModule();
  await initFieldTasksModule();
  await initFieldManagementModule();
  await initHomeModule();
}

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    // 1. connectivity_plus ile hızlı ön kontrol
    final result = await connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      // Bazı cihazlarda yanlış 'none' dönebilir; gerçek TCP ile doğrula
      return _verifyWithSocket();
    }
    return true;
  }

  /// Google DNS'e (8.8.8.8:53) 3 saniyelik TCP bağlantısı deniyor.
  /// Bağlanabilirse internet var demektir.
  Future<bool> _verifyWithSocket() async {
    try {
      final socket = await Socket.connect('8.8.8.8', 53,
          timeout: const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}

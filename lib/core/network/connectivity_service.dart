import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ağ bağlantı durumunu izleyen servis arayüzü.
abstract class ConnectivityService {
  Stream<bool> get onConnectivityChanged;
  Future<bool> checkIsConnected();
}

/// connectivity_plus paketini kullanan gerçek ağ izleme servisi.
class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return false;
    }
    return !results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  @override
  Future<bool> checkIsConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasConnection(results);
    } catch (_) {
      return true;
    }
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityPlusService();
});

/// Cihazın çevrimdışı (offline) olup olmadığını yayınlayan sağlayıcı.
final isOfflineStreamProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  final initialConnected = await service.checkIsConnected();
  yield !initialConnected;
  await for (final isConnected in service.onConnectivityChanged) {
    yield !isConnected;
  }
});

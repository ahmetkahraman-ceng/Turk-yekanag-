import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama çalışma ortamları (Flavor).
enum AppFlavor {
  dev,
  prod,
}

/// Aktif ortam (flavor) ve emülatör ayarlarını tutan yapılandırma sınıfı.
class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.appNameSuffix,
    required this.useFirebaseEmulator,
    required this.emulatorHost,
  });

  factory AppEnvironment.dev() {
    const useEmulator = bool.fromEnvironment(
      'USE_FIREBASE_EMULATOR',
      defaultValue: true,
    );
    const host = String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: '127.0.0.1',
    );
    return const AppEnvironment(
      flavor: AppFlavor.dev,
      appNameSuffix: ' (DEV)',
      useFirebaseEmulator: useEmulator,
      emulatorHost: host,
    );
  }

  factory AppEnvironment.prod() {
    const useEmulator = bool.fromEnvironment(
      'USE_FIREBASE_EMULATOR',
      defaultValue: false,
    );
    const host = String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: '127.0.0.1',
    );
    return const AppEnvironment(
      flavor: AppFlavor.prod,
      appNameSuffix: '',
      useFirebaseEmulator: useEmulator,
      emulatorHost: host,
    );
  }

  final AppFlavor flavor;
  final String appNameSuffix;
  final bool useFirebaseEmulator;
  final String emulatorHost;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return AppEnvironment.dev();
});

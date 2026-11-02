import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/core/utils/version_comparator.dart';

/// Uygulamanın mevcut çalışma sürümünü sağlayan sağlayıcı.
final currentAppVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isNotEmpty) {
      return info.version;
    }
  } catch (_) {}
  return '1.0.0';
});

/// Force Update kontrol sonucu modeli.
class ForceUpdateStatus {
  const ForceUpdateStatus({
    required this.isRequired,
    required this.currentVersion,
    required this.minVersion,
  });

  final bool isRequired;
  final String currentVersion;
  final String minVersion;
}

/// Remote Config `min_version` ile cihazdaki sürümü karşılaştırır.
final forceUpdateStatusProvider = FutureProvider<ForceUpdateStatus>((ref) async {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final currentVersion = await ref.watch(currentAppVersionProvider.future);
  final minVersion = remoteConfig.minVersion;

  final isRequired = VersionComparator.isUpdateRequired(
    currentVersion: currentVersion,
    minVersion: minVersion,
  );

  return ForceUpdateStatus(
    isRequired: isRequired,
    currentVersion: currentVersion,
    minVersion: minVersion,
  );
});

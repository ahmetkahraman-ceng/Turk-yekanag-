import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote Config anahtarları.
/// NOT: Tıbbi bilgilerde (bağış aralıkları, uygunluk kuralları) ve talep limitlerinde
/// değerler doğrudan UI/iş mantığına gömülmez, Remote Config üzerinden okunur.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
abstract final class RemoteConfigKeys {
  static const String minVersion = 'min_version';
  static const String wholeBloodIntervalDaysMale =
      'whole_blood_interval_days_male';
  static const String wholeBloodIntervalDaysFemale =
      'whole_blood_interval_days_female';
  static const String apheresisIntervalHours = 'apheresis_interval_hours';
  static const String minDonorAge = 'min_donor_age';
  static const String maxDonorAge = 'max_donor_age';
  static const String minDonorWeightKg = 'min_donor_weight_kg';
  static const String maxActiveRequestsPerUser = 'max_active_requests_per_user';
  static const String maxDailyRequestsPerUser = 'max_daily_requests_per_user';
  static const String expiryHoursCritical = 'expiry_hours_critical';
  static const String expiryHoursToday = 'expiry_hours_today';
  static const String expiryHoursThisWeek = 'expiry_hours_this_week';
  static const String stagedNotifExpandMinutes = 'staged_notif_expand_minutes';
}

/// Remote Config servisi arayüzü.
abstract class RemoteConfigService {
  Future<void> initialize();
  String get minVersion;

  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  int get wholeBloodIntervalDaysMale;
  int get wholeBloodIntervalDaysFemale;
  int get apheresisIntervalHours;
  int get minDonorAge;
  int get maxDonorAge;
  int get minDonorWeightKg;

  // Talep limitleri ve süreleri
  int get maxActiveRequestsPerUser;
  int get maxDailyRequestsPerUser;
  int get expiryHoursCritical;
  int get expiryHoursToday;
  int get expiryHoursThisWeek;
  int get stagedNotifExpandMinutes;
}

/// Firebase Remote Config uygulayıcısı.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService({
    FirebaseRemoteConfig? remoteConfig,
    Map<String, Object>? fallbackValues,
  })  : _remoteConfig = remoteConfig,
        _fallbackValues = fallbackValues ?? defaultValues;

  final FirebaseRemoteConfig? _remoteConfig;
  final Map<String, Object> _fallbackValues;

  /// Varsayılan Remote Config değerleri (yalnızca bağlantı yokken/ilk açılışta fallback olarak kullanılır).
  /// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
  static const Map<String, Object> defaultValues = <String, Object>{
    RemoteConfigKeys.minVersion: '1.0.0',
    RemoteConfigKeys.wholeBloodIntervalDaysMale: 90,
    RemoteConfigKeys.wholeBloodIntervalDaysFemale: 120,
    RemoteConfigKeys.apheresisIntervalHours: 48,
    RemoteConfigKeys.minDonorAge: 18,
    RemoteConfigKeys.maxDonorAge: 65,
    RemoteConfigKeys.minDonorWeightKg: 50,
    RemoteConfigKeys.maxActiveRequestsPerUser: 2,
    RemoteConfigKeys.maxDailyRequestsPerUser: 3,
    RemoteConfigKeys.expiryHoursCritical: 24,
    RemoteConfigKeys.expiryHoursToday: 48,
    RemoteConfigKeys.expiryHoursThisWeek: 168,
    RemoteConfigKeys.stagedNotifExpandMinutes: 15,
  };

  @override
  Future<void> initialize() async {
    final rc = _remoteConfig;
    if (rc == null) return;
    try {
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 3),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 5)
              : const Duration(hours: 1),
        ),
      );
      await rc.setDefaults(_fallbackValues);
      if (rc.app.options.apiKey != 'demo-dev-api-key' &&
          rc.app.options.apiKey != 'prod-api-key-placeholder') {
        await rc.fetchAndActivate();
      }
    } catch (error) {
      debugPrint('RemoteConfig fetch uyarısı (varsayılanlar aktif): $error');
    }
  }

  String _getString(String key) {
    final rc = _remoteConfig;
    if (rc != null) {
      try {
        final value = rc.getString(key);
        if (value.isNotEmpty) return value;
      } catch (_) {}
    }
    return (_fallbackValues[key] as String?) ?? '';
  }

  int _getInt(String key) {
    final rc = _remoteConfig;
    if (rc != null) {
      try {
        final value = rc.getInt(key);
        if (value > 0) return value;
      } catch (_) {}
    }
    return (_fallbackValues[key] as int?) ?? 0;
  }

  @override
  String get minVersion => _getString(RemoteConfigKeys.minVersion);

  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  @override
  int get wholeBloodIntervalDaysMale =>
      _getInt(RemoteConfigKeys.wholeBloodIntervalDaysMale);

  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  @override
  int get wholeBloodIntervalDaysFemale =>
      _getInt(RemoteConfigKeys.wholeBloodIntervalDaysFemale);

  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  @override
  int get apheresisIntervalHours =>
      _getInt(RemoteConfigKeys.apheresisIntervalHours);

  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  @override
  int get minDonorAge => _getInt(RemoteConfigKeys.minDonorAge);

  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  @override
  int get maxDonorAge => _getInt(RemoteConfigKeys.maxDonorAge);

  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  @override
  int get minDonorWeightKg => _getInt(RemoteConfigKeys.minDonorWeightKg);

  @override
  int get maxActiveRequestsPerUser =>
      _getInt(RemoteConfigKeys.maxActiveRequestsPerUser);

  @override
  int get maxDailyRequestsPerUser =>
      _getInt(RemoteConfigKeys.maxDailyRequestsPerUser);

  @override
  int get expiryHoursCritical => _getInt(RemoteConfigKeys.expiryHoursCritical);

  @override
  int get expiryHoursToday => _getInt(RemoteConfigKeys.expiryHoursToday);

  @override
  int get expiryHoursThisWeek => _getInt(RemoteConfigKeys.expiryHoursThisWeek);

  @override
  int get stagedNotifExpandMinutes =>
      _getInt(RemoteConfigKeys.stagedNotifExpandMinutes);
}

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return FirebaseRemoteConfigService();
});

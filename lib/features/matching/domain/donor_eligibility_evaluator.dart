import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/notification_preferences.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Bağışçı uygunluk ve bildirim filtreleme değerlendiricisi.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
abstract final class DonorEligibilityEvaluator {
  /// Bağışçının son bağış tarihinden itibaren yeterli süre geçip geçmediğini
  /// ve `isAvailableToDonate` anahtarının açık olup olmadığını kontrol eder.
  /// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
  static bool canDonateNow({
    required bool isAvailableToDonate,
    required UserGender gender,
    required RemoteConfigService remoteConfig,
    required DateTime nowUtc,
    DateTime? lastWholeBloodDonationUtc,
    DateTime? lastApheresisDonationUtc,
    BloodProductType requestedProduct = BloodProductType.wholeBlood,
  }) {
    if (!isAvailableToDonate) return false;

    if (requestedProduct.isApheresis) {
      if (lastApheresisDonationUtc != null) {
        final hoursSince = nowUtc.difference(lastApheresisDonationUtc).inHours;
        if (hoursSince < remoteConfig.apheresisIntervalHours) {
          return false;
        }
      }
      return true;
    }

    if (lastWholeBloodDonationUtc != null) {
      final requiredDays = gender == UserGender.female
          ? remoteConfig.wholeBloodIntervalDaysFemale
          : remoteConfig.wholeBloodIntervalDaysMale;
      final daysSince = nowUtc.difference(lastWholeBloodDonationUtc).inDays;
      if (daysSince < requiredDays) {
        return false;
      }
    }
    return true;
  }

  /// Kullanıcının bildirim tercihlerine (mesafe yarıçapı, aciliyet seviyesi, sessiz saatler)
  /// göre anlık bildirim alıp alamayacağını değerlendirir.
  static bool shouldReceiveNotification({
    required NotificationPreferences preferences,
    required RequestUrgency requestUrgency,
    required double distanceKm,
    required int currentLocalHour,
  }) {
    if (distanceKm > preferences.radiusKm) {
      return false;
    }

    switch (preferences.minUrgency) {
      case NotificationUrgencyFilter.all:
        break;
      case NotificationUrgencyFilter.urgentOnly:
        if (requestUrgency == RequestUrgency.thisWeek) return false;
      case NotificationUrgencyFilter.criticalOnly:
        if (requestUrgency != RequestUrgency.critical) return false;
    }

    if (preferences.quietHoursEnabled) {
      final inQuietWindow = _isInQuietHours(
        hour: currentLocalHour,
        startHour: preferences.quietStartHour,
        endHour: preferences.quietEndHour,
      );
      if (inQuietWindow) {
        if (preferences.allowCriticalInQuietHours &&
            requestUrgency == RequestUrgency.critical) {
          return true;
        }
        return false;
      }
    }

    return true;
  }

  static bool _isInQuietHours({
    required int hour,
    required int startHour,
    required int endHour,
  }) {
    if (startHour == endHour) return false;
    if (startHour > endHour) {
      // Gece yarısını aşan pencere (Örn: 23:00 - 07:00)
      return hour >= startHour || hour < endHour;
    }
    return hour >= startHour && hour < endHour;
  }
}

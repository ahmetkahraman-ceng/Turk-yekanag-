import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Bağışlar arası bekleme süreleri politikası.
///
/// Değerler KODA GÖMÜLMEZ; [RemoteConfigService] üzerinden okunur.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class DonationIntervalPolicy {
  const DonationIntervalPolicy({
    required this.wholeBloodDaysMale,
    required this.wholeBloodDaysFemale,
    required this.plateletHours,
    required this.plasmaDays,
  });

  /// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
  factory DonationIntervalPolicy.fromRemoteConfig(RemoteConfigService rc) {
    int safeRead(int Function() getter, int fallbackKeyDefault) {
      try {
        return getter();
      } catch (_) {
        return fallbackKeyDefault;
      }
    }

    const defaults = FirebaseRemoteConfigService.defaultValues;
    return DonationIntervalPolicy(
      wholeBloodDaysMale: safeRead(
        () => rc.wholeBloodIntervalDaysMale,
        defaults[RemoteConfigKeys.wholeBloodIntervalDaysMale]! as int,
      ),
      wholeBloodDaysFemale: safeRead(
        () => rc.wholeBloodIntervalDaysFemale,
        defaults[RemoteConfigKeys.wholeBloodIntervalDaysFemale]! as int,
      ),
      plateletHours: safeRead(
        () => rc.apheresisIntervalHours,
        defaults[RemoteConfigKeys.apheresisIntervalHours]! as int,
      ),
      plasmaDays: safeRead(
        () => rc.plasmaIntervalDays,
        defaults[RemoteConfigKeys.plasmaIntervalDays]! as int,
      ),
    );
  }

  final int wholeBloodDaysMale;
  final int wholeBloodDaysFemale;
  final int plateletHours;
  final int plasmaDays;

  /// Yapılan bağışın ürün tipine ve cinsiyete göre bir sonraki bağışa kadar
  /// beklenmesi gereken süre.
  ///
  /// Varsayımlar (RAPOR.md):
  /// - Eritrosit bağışı tam kan ile aynı aralığa tabi tutulur.
  /// - Cinsiyet belirtilmemişse daha uzun (ihtiyatlı) olan kadın aralığı kullanılır.
  /// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
  Duration waitingPeriodAfter({
    required BloodProductType donatedProduct,
    required UserGender gender,
  }) {
    switch (donatedProduct) {
      case BloodProductType.platelet:
        return Duration(hours: plateletHours);
      case BloodProductType.plasma:
        return Duration(days: plasmaDays);
      case BloodProductType.wholeBlood:
      case BloodProductType.erythrocyte:
        final days = gender == UserGender.male
            ? wholeBloodDaysMale
            : wholeBloodDaysFemale;
        return Duration(days: days);
    }
  }
}

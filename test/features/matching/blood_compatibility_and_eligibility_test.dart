import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/matching/domain/blood_compatibility_engine.dart';
import 'package:turkiye_kan_agi/features/matching/domain/donor_eligibility_evaluator.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/notification_preferences.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

void main() {
  group('BloodCompatibilityEngine — Tüm ABO/Rh ve Ürün Tipi Matrisi', () {
    test('UNKNOWN kan grubu hiçbir ürün tipinde uyumlu kabul edilmez', () {
      for (final product in BloodProductType.values) {
        for (final known in BloodType.knownTypes) {
          expect(
            BloodCompatibilityEngine.isCompatible(
              donor: BloodType.unknown,
              recipient: known,
              productType: product,
            ),
            isFalse,
          );
          expect(
            BloodCompatibilityEngine.isCompatible(
              donor: known,
              recipient: BloodType.unknown,
              productType: product,
            ),
            isFalse,
          );
        }
      }
    });

    test('Tam Kan (wholeBlood) yalnızca birebir aynı ABO ve Rh (izogrup) ile uyumludur', () {
      for (final donor in BloodType.knownTypes) {
        for (final recipient in BloodType.knownTypes) {
          final expected = donor == recipient;
          expect(
            BloodCompatibilityEngine.isCompatible(
              donor: donor,
              recipient: recipient,
              productType: BloodProductType.wholeBlood,
            ),
            expected,
            reason: 'Donor ${donor.code} -> Recipient ${recipient.code}',
          );
        }
      }
    });

    test('Eritrosit (erythrocyte): 0 Rh(-) genel verici, AB Rh(+) genel alıcıdır ve tüm 64 kombinasyon doğrulanır', () {
      final expectedCompatiblesForRecipient = <BloodType, Set<BloodType>>{
        BloodType.oNeg: {BloodType.oNeg},
        BloodType.oPos: {BloodType.oNeg, BloodType.oPos},
        BloodType.aNeg: {BloodType.oNeg, BloodType.aNeg},
        BloodType.aPos: {
          BloodType.oNeg,
          BloodType.oPos,
          BloodType.aNeg,
          BloodType.aPos,
        },
        BloodType.bNeg: {BloodType.oNeg, BloodType.bNeg},
        BloodType.bPos: {
          BloodType.oNeg,
          BloodType.oPos,
          BloodType.bNeg,
          BloodType.bPos,
        },
        BloodType.abNeg: {
          BloodType.oNeg,
          BloodType.aNeg,
          BloodType.bNeg,
          BloodType.abNeg,
        },
        BloodType.abPos: BloodType.knownTypes.toSet(),
      };

      for (final recipient in BloodType.knownTypes) {
        final actualSet = BloodCompatibilityEngine.compatibleDonorTypesFor(
          recipient: recipient,
          productType: BloodProductType.erythrocyte,
        ).toSet();
        expect(
          actualSet,
          expectedCompatiblesForRecipient[recipient],
          reason: 'Eritrosit alıcı ${recipient.code} uyum kümesi hatalı',
        );
      }
    });

    test('Taze Donmuş Plazma (plasma): Eritrosit ABO uyumunun tersidir (AB genel verici, 0 genel alıcı)', () {
      // AB plazma tüm ABO gruplarına verebilir
      for (final recipient in BloodType.knownTypes) {
        expect(
          BloodCompatibilityEngine.isCompatible(
            donor: BloodType.abPos,
            recipient: recipient,
            productType: BloodProductType.plasma,
          ),
          isTrue,
        );
        expect(
          BloodCompatibilityEngine.isCompatible(
            donor: BloodType.abNeg,
            recipient: recipient,
            productType: BloodProductType.plasma,
          ),
          isTrue,
        );
      }

      // 0 grubu plazma sadece 0 grubu alıcıya verebilir (A, B, AB'ye veremez)
      expect(
        BloodCompatibilityEngine.isCompatible(
          donor: BloodType.oNeg,
          recipient: BloodType.aPos,
          productType: BloodProductType.plasma,
        ),
        isFalse,
      );
      expect(
        BloodCompatibilityEngine.isCompatible(
          donor: BloodType.oPos,
          recipient: BloodType.oNeg,
          productType: BloodProductType.plasma,
        ),
        isTrue,
      );
    });

    test('Trombosit (platelet): ABO özdeşliği ve Rh hücre uyumu aranır', () {
      expect(
        BloodCompatibilityEngine.isCompatible(
          donor: BloodType.aNeg,
          recipient: BloodType.aPos,
          productType: BloodProductType.platelet,
        ),
        isTrue,
      );
      expect(
        BloodCompatibilityEngine.isCompatible(
          donor: BloodType.aPos,
          recipient: BloodType.aNeg,
          productType: BloodProductType.platelet,
        ),
        isFalse,
      );
      expect(
        BloodCompatibilityEngine.isCompatible(
          donor: BloodType.oNeg,
          recipient: BloodType.aPos,
          productType: BloodProductType.platelet,
        ),
        isFalse,
      );
    });
  });

  group('DonorEligibilityEvaluator — Bağış Aralığı ve Sessiz Saat Filtreleri', () {
    final rc = FirebaseRemoteConfigService();
    final now = DateTime.utc(2026, 6, 1, 12);

    test('Son tam kan bağışından yeterli süre geçmemişse veya uygun değilim seçiliyse false döner', () {
      expect(
        DonorEligibilityEvaluator.canDonateNow(
          isAvailableToDonate: false,
          gender: UserGender.male,
          remoteConfig: rc,
          nowUtc: now,
        ),
        isFalse,
      );

      // Erkek için 90 gün kuralı: 45 gün önce bağış yapmışsa uygun değil
      expect(
        DonorEligibilityEvaluator.canDonateNow(
          isAvailableToDonate: true,
          gender: UserGender.male,
          remoteConfig: rc,
          nowUtc: now,
          lastWholeBloodDonationUtc: now.subtract(const Duration(days: 45)),
        ),
        isFalse,
      );

      // 95 gün önce bağış yapmışsa uygun
      expect(
        DonorEligibilityEvaluator.canDonateNow(
          isAvailableToDonate: true,
          gender: UserGender.male,
          remoteConfig: rc,
          nowUtc: now,
          lastWholeBloodDonationUtc: now.subtract(const Duration(days: 95)),
        ),
        isTrue,
      );
    });

    test('Sessiz saatlerde normal talepler engellenir, allowCriticalInQuietHours açıksa kritik talep geçer', () {
      const prefs = NotificationPreferences(
        radiusKm: 25,
        quietHoursEnabled: true,
        quietStartHour: 23,
        quietEndHour: 7,
        allowCriticalInQuietHours: true,
      );

      // Gece 02:00'de "Bugün" aciliyetli talep bildirim göndermez
      expect(
        DonorEligibilityEvaluator.shouldReceiveNotification(
          preferences: prefs,
          requestUrgency: RequestUrgency.today,
          distanceKm: 10,
          currentLocalHour: 2,
        ),
        isFalse,
      );

      // Gece 02:00'de "Acil (Kritik)" talep bildirim gönderir
      expect(
        DonorEligibilityEvaluator.shouldReceiveNotification(
          preferences: prefs,
          requestUrgency: RequestUrgency.critical,
          distanceKm: 10,
          currentLocalHour: 2,
        ),
        isTrue,
      );
    });
  });
}

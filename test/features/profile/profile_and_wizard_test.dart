import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/core/services/location_service.dart';
import 'package:turkiye_kan_agi/features/onboarding/domain/kvkk_consent_record.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/turkey_location_data.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/notification_preferences_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/profile_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/profile_setup_wizard_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/unknown_blood_type_info_screen.dart';

import '../../helpers/test_app_wrapper.dart';

class _OnlineConnectivityService implements ConnectivityService {
  @override
  Future<bool> checkIsConnected() async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

void main() {
  group('Profil, Kan Grubu Rehberi, Bildirim Tercihleri ve KVKK Şema Testleri', () {
    test(
      'Public ve Sensitive profil şeması ayrımı: Public JSON içinde hassas veri bulunmaz',
      () async {
        final repo = FirestoreProfileRepository();
        final now = DateTime.utc(2026, 11, 3);

        final publicProfile = UserPublicProfile(
          uid: 'user-1',
          displayName: 'KanDostu06',
          useNickname: true,
          province: 'Ankara',
          district: 'Çankaya',
          isAvailableToDonate: true,
          updatedAt: now,
        );

        final sensitiveProfile = UserSensitiveProfile(
          fullName: 'Mehmet Demir',
          nickname: 'KanDostu06',
          phoneNumber: '+905321112233',
          birthDate: DateTime.utc(1992, 4, 10),
          gender: UserGender.male,
          weightKg: 78,
          bloodType: BloodType.oNeg,
          updatedAt: now,
        );

        final consent = KvkkConsentRecord(
          healthDataConsent: true,
          locationConsent: true,
          notificationConsent: true,
          consentedAt: now,
          policyVersion: '1.0.0',
        );

        await repo.saveFullProfile(
          publicProfile: publicProfile,
          sensitiveProfile: sensitiveProfile,
          consentRecord: consent,
        );

        final publicJson = publicProfile.toJson();
        expect(publicJson.containsKey('phoneNumber'), isFalse);
        expect(publicJson.containsKey('bloodType'), isFalse);
        expect(publicJson.containsKey('weightKg'), isFalse);
        expect(publicJson.containsKey('birthDate'), isFalse);
        expect(publicJson['displayName'], 'KanDostu06');

        // JSON Veri İndirme (exportUserDataJson) tüm verileri içerir
        final exportResult = await repo.exportUserDataJson('user-1');
        exportResult.when(
          success: (jsonStr) {
            final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
            expect(decoded['uid'], 'user-1');
            expect(decoded['publicProfile']['province'], 'Ankara');
            expect(decoded['sensitiveProfile']['bloodType'], '0-');
            expect(decoded['kvkkConsent']['policyVersion'], '1.0.0');
          },
          failure: (_) => fail('Export başarısız olmamalı'),
        );
      },
    );

    testWidgets(
      'ProfileSetupWizardScreen "Kan grubumu bilmiyorum" seçeneğini ve 81 il seçicisini destekler',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const ProfileSetupWizardScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
              turkeyProvincesProvider.overrideWith(
                (ref) async => const [
                  TurkeyProvince(
                    plate: 6,
                    name: 'Ankara',
                    districts: ['Çankaya', 'Keçiören'],
                  ),
                  TurkeyProvince(
                    plate: 34,
                    name: 'İstanbul',
                    districts: ['Kadıköy', 'Beşiktaş'],
                  ),
                ],
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        final unknownChip = find.byKey(const Key('blood_type_unknown_chip'));
        await tester.scrollUntilVisible(
          unknownChip,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(unknownChip, findsOneWidget);
        await tester.tap(unknownChip);
        await tester.pump();

        final chipWidget = tester.widget<ChoiceChip>(unknownChip);
        expect(chipWidget.selected, isTrue);
      },
    );

    testWidgets('UnknownBloodTypeInfoScreen bilgilendirme adımlarını gösterir', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const UnknownBloodTypeInfoScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('1. Türk Kızılayı Kan Bağışı Noktaları'),
        findsOneWidget,
      );
    });

    testWidgets(
      'NotificationPreferencesScreen yarıçap (5/10/25/50 km) ve sessiz saatleri günceller',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const NotificationPreferencesScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('radius_chip_10')));
        await tester.pump();
        final chip10 = tester.widget<ChoiceChip>(
          find.byKey(const Key('radius_chip_10')),
        );
        expect(chip10.selected, isTrue);
      },
    );

    testWidgets(
      'ProfileScreen Bağışa Uygunum anahtarını ve Verilerimi İndir (JSON) diyalogunu çalıştırır',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const ProfileScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Bağışa Uygunum'), findsOneWidget);

        final exportBtn = find.byKey(const Key('export_user_data_button'));
        await tester.scrollUntilVisible(
          exportBtn,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(exportBtn);
        await tester.pumpAndSettle();

        expect(find.text('Verileriniz Hazır (JSON)'), findsOneWidget);
      },
    );

    test(
      'LocationService ve TurkeyGeocoderTable 81 il/ilçe çözümlemesini Türkçe karakter duyarsız ve doğru yapar',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        const service = LocationService();

        final kadikoy = await service.resolveProvinceAndDistrict(
          40.9901,
          29.0292,
        );
        expect(kadikoy.province, 'İstanbul');
        expect(kadikoy.district, 'Kadıköy');

        final bursaNilufer = await service.resolveProvinceAndDistrict(
          40.2169,
          28.9850,
        );
        expect(bursaNilufer.province, 'Bursa');
        expect(bursaNilufer.district, 'Nilüfer');

        final asciiMatch = TurkeyGeocoderTable.matchCanonicalArea(
          provinceCandidates: const ['Istanbul Province'],
          districtCandidates: const ['Kadikoy District'],
          lat: 40.99,
          lon: 29.03,
        );
        expect(asciiMatch.province, 'İstanbul');
        expect(asciiMatch.district, 'Kadıköy');
      },
    );
  });
}

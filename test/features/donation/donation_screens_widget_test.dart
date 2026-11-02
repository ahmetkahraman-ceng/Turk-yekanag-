import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/data/local_notification_reminder_service.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/donation_screen.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/donation_tips_screen.dart';
import 'package:turkiye_kan_agi/features/donation/presentation/eligibility_survey_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/domain/kvkk_consent_record.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';

import '../../helpers/test_app_wrapper.dart';

class _OnlineConnectivity implements ConnectivityService {
  @override
  Future<bool> checkIsConnected() async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

void main() {
  group('Bağış Takibi, Ön Kontrol Anketi ve Öneriler Widget Testleri', () {
    testWidgets(
      'DonationScreen manuel bağış ekler, geri sayım kartını ve takvime ekleme butonunu gösterir',
      (tester) async {
        final donationRepo = FirestoreDonationRepository();
        final profileRepo = FirestoreProfileRepository(
          donationRepository: donationRepo,
        );
        final calendarService = DeviceCalendarExportService(
          addEventFn: (_) async => true,
        );

        await tester.pumpWidget(
          buildTestableWidget(
            const DonationScreen(),
            overrides: [
              currentUserIdStateProvider.overrideWith((ref) => 'user-widget-1'),
              donationRepositoryProvider.overrideWithValue(donationRepo),
              profileRepositoryProvider.overrideWithValue(profileRepo),
              calendarExportServiceProvider.overrideWithValue(calendarService),
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivity(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Şu Anda Bağışa Uygun Görünüyorsunuz'),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const Key('open_add_manual_donation_button')),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('manual_donation_place_field')),
          'Kızılay Çankaya Merkezi',
        );
        await tester.tap(find.byKey(const Key('save_manual_donation_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('donation_countdown_text')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('add_to_calendar_button')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('add_to_calendar_button')));
        await tester.pumpAndSettle();
        expect(calendarService.lastAddedEvent, isNotNull);

        await tester.scrollUntilVisible(
          find.textContaining('Kızılay Çankaya Merkezi'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Kızılay Çankaya Merkezi'), findsOneWidget);
      },
    );

    testWidgets(
      'DonationScreen sağlık verisi açık rızası yoksa KVKK uyarı kartını gösterir',
      (tester) async {
        final donationRepo = FirestoreDonationRepository();
        final profileRepo = FirestoreProfileRepository(
          donationRepository: donationRepo,
        );
        await profileRepo.saveKvkkConsent(
          uid: 'user-no-consent',
          consent: KvkkConsentRecord(
            healthDataConsent: false,
            locationConsent: true,
            notificationConsent: true,
            consentedAt: DateTime.utc(2026, 11, 1),
            policyVersion: '1.0.0',
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(
            const DonationScreen(),
            overrides: [
              currentUserIdStateProvider.overrideWith(
                (ref) => 'user-no-consent',
              ),
              donationRepositoryProvider.overrideWithValue(donationRepo),
              profileRepositoryProvider.overrideWithValue(profileRepo),
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivity(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('kvkk_health_consent_gate_card')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('grant_health_consent_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('open_add_manual_donation_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'EligibilitySurveyScreen sağlık personeli uyarısını gösterir ve yanıtları değerlendirir',
      (tester) async {
        final donationRepo = FirestoreDonationRepository();
        final profileRepo = FirestoreProfileRepository(
          donationRepository: donationRepo,
        );

        await tester.pumpWidget(
          buildTestableWidget(
            const EligibilitySurveyScreen(),
            overrides: [
              currentUserIdStateProvider.overrideWith((ref) => 'survey-user'),
              donationRepositoryProvider.overrideWithValue(donationRepo),
              profileRepositoryProvider.overrideWithValue(profileRepo),
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivity(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Karar kan merkezindeki sağlık personelindedir'),
          findsOneWidget,
        );

        const qIds = <String>[
          'active_illness',
          'medication_use',
          'tattoo_piercing',
          'recent_surgery',
          'pregnancy_breastfeeding',
          'recent_travel',
          'recent_vaccine',
        ];
        for (final id in qIds) {
          final finder = find.byKey(Key('survey_q_${id}_no'));
          await tester.scrollUntilVisible(
            finder,
            120,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(finder);
          await tester.pump();
        }

        final evalBtn = find.byKey(const Key('evaluate_survey_button'));
        await tester.scrollUntilVisible(
          evalBtn,
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(evalBtn);
        await tester.pumpAndSettle();

        final outcomeCard = find.byKey(
          const Key('survey_outcome_card_looks_eligible'),
        );
        await tester.scrollUntilVisible(
          outcomeCard,
          120,
          scrollable: find.byType(Scrollable).first,
        );
        expect(outcomeCard, findsOneWidget);
      },
    );

    testWidgets(
      'DonationTipsScreen bağış öncesi ve sonrası önerileri gösterir',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const DonationTipsScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivity(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('tips_before_section')), findsOneWidget);
        expect(find.byKey(const Key('tips_after_section')), findsOneWidget);
      },
    );
  });
}

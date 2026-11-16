import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/login_screen.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/otp_verification_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/domain/kvkk_consent_record.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/kvkk_consent_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';

import '../../helpers/test_app_wrapper.dart';

class _OnlineConnectivityService implements ConnectivityService {
  @override
  Stream<bool> get onConnectivityChanged => Stream<bool>.value(true);

  @override
  Future<bool> checkIsConnected() async => true;
}

void main() {
  group('Aşama 2: Onboarding, KVKK, Giriş ve OTP Testleri', () {
    testWidgets('OnboardingScreen 4 slaytı gösterir ve ileri geçiş yapar', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const OnboardingScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bir damla, bir umut'), findsOneWidget);
      expect(find.text('Atla'), findsOneWidget);
      expect(find.text('İleri'), findsOneWidget);

      // 2. Slayta geç
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Yakınındaki ihtiyacı gör'), findsOneWidget);

      // 3. Slayta geç
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Tek dokunuşla yardım et'), findsOneWidget);

      // 4. Slayta geç
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Verin güvende'), findsOneWidget);
      expect(find.text('Başla'), findsOneWidget);
    });

    testWidgets(
      'KvkkConsentScreen zorunlu açık rıza kutuları onaylanmadan devam butonunu etkinleştirmez',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: buildTestableWidget(const KvkkConsentScreen()),
          ),
        );
        await tester.pumpAndSettle();

        final buttonFinder = find.descendant(
          of: find.byKey(const Key('kvkk_continue_button')),
          matching: find.byType(ElevatedButton),
        );
        expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

        // 1. Zorunlu Sağlık Verisi rızasını işaretle
        final healthCb = find.byKey(const Key('consent_health_checkbox'));
        await tester.scrollUntilVisible(
          healthCb,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(healthCb);
        await tester.pump();
        expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

        // 2. Zorunlu Konum rızasını işaretle -> artık Devam aktif olmalı
        final locCb = find.byKey(const Key('consent_location_checkbox'));
        await tester.scrollUntilVisible(
          locCb,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(locCb);
        await tester.pump();

        expect(
          tester.widget<ElevatedButton>(buttonFinder).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'LoginScreen telefon numarasını maskeler ve OtpVerificationScreen 45 sn geri sayım gösterir',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const LoginScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        final phoneField = find.byKey(const Key('phone_input_field'));
        expect(phoneField, findsOneWidget);

        await tester.enterText(phoneField, '5321234567');
        await tester.pump();

        expect(find.text('532 123 45 67'), findsOneWidget);

        // OTP ekranını kontrol et
        await tester.pumpWidget(
          buildTestableWidget(
            const OtpVerificationScreen(
              args: OtpRouteArgs(
                phoneNumber: '+905321234567',
                verificationId: 'test-verif-id',
              ),
            ),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('Kodu tekrar gönder (45 sn)'), findsOneWidget);
      },
    );

    test('KvkkConsentNotifier onay kaydını policyVersion ile oluşturur', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(kvkkConsentProvider), isNull);

      final fixedTime = DateTime.utc(2026, 3, 21, 12);
      container
          .read(kvkkConsentProvider.notifier)
          .approveAll(timestamp: fixedTime);

      final record = container.read(kvkkConsentProvider);
      expect(record, isNotNull);
      expect(record!.allMandatoryConsentsGranted, isTrue);
      expect(record.policyVersion, KvkkConsentRecord.currentPolicyVersion);
      expect(record.toJson()['consentedAt'], fixedTime.toIso8601String());
    });
  });
}

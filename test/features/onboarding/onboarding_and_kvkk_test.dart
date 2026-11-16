import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/login_screen.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/otp_verification_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/kvkk_consent_screen.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_screen.dart';

import '../../helpers/test_app_wrapper.dart';

class _OnlineConnectivityService implements ConnectivityService {
  @override
  Future<bool> checkIsConnected() async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

void main() {
  group('Aşama 2: Onboarding, KVKK, Giriş ve OTP Testleri', () {
    testWidgets('OnboardingScreen 4 slayt içerir ve İleri/Başla ile geçiş yapar', (
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

      // 1. Slayt
      expect(find.text('Bir damla, bir umut'), findsOneWidget);

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

        final buttonFinder = find.widgetWithText(ElevatedButton, 'Devam');
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

        expect(find.text('Kod Gönder'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('phone_input_field')),
          '5321112233',
        );
        await tester.pump();
        expect(find.text('532 111 22 33'), findsOneWidget);

        await tester.pumpWidget(
          buildTestableWidget(
            const OtpVerificationScreen(
              args: OtpRouteArgs(
                phoneNumber: '+905321112233',
                verificationId: 'test-ver-id',
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
        expect(find.textContaining('45 sn'), findsOneWidget);
      },
    );
  });
}

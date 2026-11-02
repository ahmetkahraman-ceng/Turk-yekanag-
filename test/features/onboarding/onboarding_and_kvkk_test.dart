import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
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
  group('Onboarding ve KVKK Açık Rıza Testleri', () {
    testWidgets('OnboardingScreen 4 slayt içerir ve İleri ile geçiş yapar', (
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
      expect(find.text('Gönüllü Kan Dayanışması'), findsOneWidget);

      // 2. Slayta geç
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Nasıl Çalışır?'), findsOneWidget);

      // 3. Slayta geç
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Kişisel Verileriniz Güvende'), findsOneWidget);

      // 4. Slayta geç
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
      expect(find.text('Konum İzni Neden Gerekli?'), findsOneWidget);
      expect(find.text('Devam Et'), findsOneWidget);
    });

    testWidgets(
      'KvkkConsentScreen 3 ayrı açık rıza kutusu onaylanmadan devam butonunu etkinleştirmez',
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

        final buttonFinder = find.widgetWithText(
          ElevatedButton,
          'Açık Rıza Ver ve Devam Et',
        );
        expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

        // 3 onay kutusunu sırayla işaretle
        final healthCb = find.byKey(const Key('consent_health_checkbox'));
        await tester.ensureVisible(healthCb);
        await tester.pumpAndSettle();
        await tester.tap(healthCb);
        await tester.pump();
        expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

        final locCb = find.byKey(const Key('consent_location_checkbox'));
        await tester.ensureVisible(locCb);
        await tester.pumpAndSettle();
        await tester.tap(locCb);
        await tester.pump();
        expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

        final notifCb = find.byKey(const Key('consent_notification_checkbox'));
        await tester.ensureVisible(notifCb);
        await tester.pumpAndSettle();
        await tester.tap(notifCb);
        await tester.pump();

        expect(
          tester.widget<ElevatedButton>(buttonFinder).onPressed,
          isNotNull,
        );
      },
    );
  });
}

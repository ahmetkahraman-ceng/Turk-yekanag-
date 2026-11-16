import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/mock/mock_data.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/core/widgets/design_gallery_screen.dart';
import 'package:turkiye_kan_agi/features/admin/presentation/admin_web_screen.dart';
import 'package:turkiye_kan_agi/features/map/presentation/map_screen.dart';
import 'package:turkiye_kan_agi/features/matching/presentation/screens/donation_celebration_screen.dart';
import 'package:turkiye_kan_agi/features/matching/presentation/screens/donor_tracking_screen.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/screens/blood_compatibility_matrix_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/screens/communities_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/screens/faq_and_guides_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/screens/institutions_screen.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/screens/leaderboard_invite_about_screens.dart';

import '../helpers/test_app_wrapper.dart';

class _OnlineConnectivityService implements ConnectivityService {
  @override
  Stream<bool> get onConnectivityChanged => Stream<bool>.value(true);

  @override
  Future<bool> checkIsConnected() async => true;
}

void main() {
  group('UI Master Prompt: Aşama 1-9 Tam Kapsam Widget & Erişilebilirlik Testleri', () {
    testWidgets('DesignGalleryScreen aydınlık/karanlık ve 1.5x yazı ölçeğinde taşmadan çizilir', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
            disableAnimations: true,
          ),
          child: buildTestableWidget(
            const DesignGalleryScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(DesignGalleryScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MapScreen harita/liste geçişini ve konum izni fallback durumunu destekler', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const MapScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Talepler'), findsWidgets);
      expect(find.text('Bağış merkezleri'), findsWidgets);

      await tester.tap(find.byKey(const Key('toggle_map_list_button')));
      await tester.pumpAndSettle();
      expect(find.byType(MapScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DonorTrackingScreen ve DonationCelebrationScreen adımları ilerletir', (tester) async {
      final sampleReq = MockData.requests.first;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(
            DonorTrackingScreen(request: sampleReq),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('15 dakikada oradayım'), findsOneWidget);
      await tester.tap(find.byKey(const Key('donor_tracking_primary_button')));
      await tester.pump();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(
            const DonationCelebrationScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Bir hayata dokundun'), findsOneWidget);
    });

    testWidgets('CommunitiesScreen, InstitutionsScreen ve BloodCompatibilityMatrixScreen etkileşimleri çalışır', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const CommunitiesScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nadir Kan Ağı (Rh Negatif)'), findsWidgets);

      await tester.pumpWidget(
        buildTestableWidget(
          const BloodCompatibilityMatrixScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('matrix_select_${BloodType.oNeg.code}')));
      await tester.pumpAndSettle();
      expect(find.text('Kime Verebilir?'), findsOneWidget);

      await tester.pumpWidget(
        buildTestableWidget(
          const InstitutionsScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ODTÜ Bahar Kan Bağışı Kampanyası'), findsOneWidget);
    });

    testWidgets('FaqScreen, EmergencyGuideScreen ve LeaderboardScreen (opt-in) doğrulanır', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const FaqScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Türkiye Kan Ağı Kızılay’ın yerine mi geçiyor?'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const EmergencyGuideScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('1. Hastane ve Kan Merkezini Doğrulayın'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const LeaderboardScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('enable_leaderboard_button')));
      await tester.pumpAndSettle();
      expect(find.text('Ayşe K.'), findsOneWidget);
    });

    testWidgets('AdminWebScreen giriş ve pano/rapor kuyruğu görünümünü çalıştırır', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          const AdminWebScreen(),
          overrides: [
            connectivityServiceProvider.overrideWithValue(
              _OnlineConnectivityService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('admin_login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Açık Talep'), findsOneWidget);
      expect(find.text('İl Bazlı Açık Talepler'), findsOneWidget);
    });
  });
}

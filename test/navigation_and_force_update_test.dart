import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:turkiye_kan_agi/app.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/core/services/app_version_service.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class FakeConnectivityService implements ConnectivityService {
  @override
  Future<bool> checkIsConnected() async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

void main() {
  late MockRemoteConfigService mockRemoteConfig;

  setUp(() {
    mockRemoteConfig = MockRemoteConfigService();
    when(() => mockRemoteConfig.wholeBloodIntervalDaysMale).thenReturn(90);
    when(() => mockRemoteConfig.wholeBloodIntervalDaysFemale).thenReturn(120);
    when(() => mockRemoteConfig.apheresisIntervalHours).thenReturn(48);
    when(() => mockRemoteConfig.minDonorAge).thenReturn(18);
    when(() => mockRemoteConfig.maxDonorAge).thenReturn(65);
    when(() => mockRemoteConfig.minDonorWeightKg).thenReturn(50);
  });

  testWidgets(
    'Sürüm güncelse Splash sonrasında 5 sekmeli ana navigasyon açılır ve sekmeler arası geçiş yapılır',
    (tester) async {
      when(() => mockRemoteConfig.minVersion).thenReturn('1.0.0');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteConfigServiceProvider.overrideWithValue(mockRemoteConfig),
            currentAppVersionProvider.overrideWith((ref) async => '1.0.0'),
            connectivityServiceProvider.overrideWithValue(
              FakeConnectivityService(),
            ),
          ],
          child: const TurkiyeKanAgiApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Alt navigasyon sekmeleri görünür olmalı
      expect(find.text('Talepler'), findsOneWidget);
      expect(find.text('Harita'), findsOneWidget);
      expect(find.text('Bağış'), findsOneWidget);
      expect(find.text('Bildirimler'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Harita sekmesine geçiş
      await tester.tap(find.text('Harita'));
      await tester.pumpAndSettle();
      expect(find.text('Talep Haritası'), findsOneWidget);

      // Bağış sekmesine geçiş (Remote Config değerleri gösterilmeli)
      await tester.tap(find.text('Bağış'));
      await tester.pumpAndSettle();
      expect(find.text('Bağış Rehberi'), findsOneWidget);
      expect(find.textContaining('90'), findsOneWidget);
      expect(find.textContaining('120'), findsOneWidget);
    },
  );

  testWidgets(
    'Remote Config min_version mevcut sürümden büyükse Force Update ekranına yönlendirir',
    (tester) async {
      when(() => mockRemoteConfig.minVersion).thenReturn('2.0.0');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remoteConfigServiceProvider.overrideWithValue(mockRemoteConfig),
            currentAppVersionProvider.overrideWith((ref) async => '1.0.0'),
            connectivityServiceProvider.overrideWithValue(
              FakeConnectivityService(),
            ),
          ],
          child: const TurkiyeKanAgiApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Güncelleme Gerekli'), findsOneWidget);
      expect(find.text('Mağazadan Güncelle'), findsOneWidget);
    },
  );
}

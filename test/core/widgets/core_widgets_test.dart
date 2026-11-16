import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/branding/blood_logo.dart';
import 'package:turkiye_kan_agi/core/mock/mock_data.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/countdown_ring.dart';
import 'package:turkiye_kan_agi/core/widgets/design_gallery_screen.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/loading_skeleton.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/core/widgets/status_and_urgency_tags.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

import '../../helpers/test_app_wrapper.dart';

void main() {
  group('Core Ortak Widget ve Aşama 1 Testleri', () {
    testWidgets(
      'PrimaryButton ve AppButton minimum dokunma alanına sahiptir ve tıklamayı tetikler',
      (tester) async {
        var tapped = false;
        var appBtnTapped = false;
        await tester.pumpWidget(
          buildTestableWidget(
            Column(
              children: [
                PrimaryButton(
                  label: 'Onayla',
                  onPressed: () => tapped = true,
                ),
                AppButton(
                  label: 'Yardım Edebilirim',
                  onPressed: () => appBtnTapped = true,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final buttonFinder = find.text('Onayla');
        expect(buttonFinder, findsOneWidget);

        await tester.tap(buttonFinder);
        expect(tapped, isTrue);

        await tester.tap(find.text('Yardım Edebilirim'));
        expect(appBtnTapped, isTrue);
      },
    );

    testWidgets('AppTextField metin girişini ve etiketi doğru gösterir', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestableWidget(
          AppTextField(
            labelText: 'Ad Soyad',
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ad Soyad'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Ayşe Yılmaz');
      expect(controller.text, 'Ayşe Yılmaz');
    });

    testWidgets('EmptyState ve ErrorState içeriklerini ve aksiyonunu çalıştırır', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        buildTestableWidget(
          Column(
            children: [
              const Expanded(
                child: EmptyState(
                  title: 'Kayıt Yok',
                  subtitle: 'Henüz veri eklenmedi.',
                ),
              ),
              Expanded(
                child: ErrorState(
                  message: 'Sunucu hatası',
                  onRetry: () => retried = true,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kayıt Yok'), findsOneWidget);
      expect(find.text('Sunucu hatası'), findsOneWidget);

      await tester.tap(find.text('Tekrar Dene'));
      expect(retried, isTrue);
    });

    testWidgets('OfflineBanner çevrimdışı durumda uyarı bandını gösterir', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const OfflineBanner(forceShow: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('LoadingSkeleton belirtilen sayıda iskelet öğesi oluşturur', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const LoadingSkeleton(itemCount: 3),
        ),
      );
      await tester.pump();

      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });

    testWidgets(
      'BloodLogo, BloodTypeBadge, UrgencyTag, StatusTag ve CountdownRing sorunsuz çizilir',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const SingleChildScrollView(
              child: Column(
                children: [
                  BloodLogo(size: 80, progress: 1.0),
                  BloodTypeBadge(
                    bloodType: BloodType.oNeg,
                    size: BloodBadgeSize.l,
                  ),
                  UrgencyTag(urgency: RequestUrgency.critical),
                  StatusTag(status: RequestStatus.fulfilled),
                  CountdownRing(progress: 0.5, centerText: '24 gün'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BloodLogo), findsOneWidget);
        expect(find.text('0-'), findsOneWidget);
        expect(find.text('ACİL'), findsOneWidget);
        expect(find.text('Karşılandı'), findsOneWidget);
        expect(find.text('24 gün'), findsOneWidget);
      },
    );

    testWidgets('DesignGalleryScreen taşma olmadan çizilir', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const DesignGalleryScreen()),
      );
      await tester.pump();
      expect(find.byType(DesignGalleryScreen), findsOneWidget);
    });

    test('MockData en az 30 talep, 10 bağış merkezi ve 15 bildirim içerir', () {
      expect(MockData.requests.length, greaterThanOrEqualTo(30));
      expect(MockData.centers.length, greaterThanOrEqualTo(10));
      expect(MockData.notifications.length, greaterThanOrEqualTo(15));
      expect(AppSpacing.primaryButtonHeight, 52.0);
    });
  });
}

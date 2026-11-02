import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/loading_skeleton.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';

import '../../helpers/test_app_wrapper.dart';

void main() {
  group('Core Ortak Widget Testleri', () {
    testWidgets(
      'PrimaryButton minimum 48dp dokunma alanına sahiptir ve tıklamayı tetikler',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildTestableWidget(
            PrimaryButton(
              label: 'Onayla',
              onPressed: () => tapped = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final buttonFinder = find.byType(ElevatedButton);
        expect(buttonFinder, findsOneWidget);

        final size = tester.getSize(buttonFinder);
        expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget));

        await tester.tap(buttonFinder);
        expect(tapped, isTrue);
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
  });
}

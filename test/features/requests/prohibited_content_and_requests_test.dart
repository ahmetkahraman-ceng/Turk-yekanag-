import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/network/connectivity_service.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/fcm_notification_service.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/matching/data/firestore_matching_repository.dart';
import 'package:turkiye_kan_agi/features/matching/domain/donation_offer.dart';
import 'package:turkiye_kan_agi/features/notifications/presentation/notifications_screen.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/hospital.dart';
import 'package:turkiye_kan_agi/features/requests/domain/prohibited_content_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/create_request_wizard_screen.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/request_detail_screen.dart';

import '../../helpers/test_app_wrapper.dart';

class _OnlineConnectivityService implements ConnectivityService {
  @override
  Future<bool> checkIsConnected() async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

void main() {
  group('ProhibitedContentFilter, Talep Limitleri ve Eşleştirme Testleri', () {
    test('Para, ücret ve IBAN içeren ifadeler engellenir; temiz metinler onaylanır', () {
      expect(
        ProhibitedContentFilter.containsProhibitedContent(
          'Acil 2 ünite kan lazım, 5000 TL nakit ödeme yapılacaktır',
        ),
        isTrue,
      );
      expect(
        ProhibitedContentFilter.containsProhibitedContent(
          'TR33 0006 1005 1978 6457 8413 26 iban numarasına ücret',
        ),
        isTrue,
      );
      expect(
        ProhibitedContentFilter.containsProhibitedContent(
          'Yoğun bakım servisinde yatan hastamız için gönüllü bağışçı aranmaktadır.',
        ),
        isFalse,
      );
    });

    test('Hasta adı yalnızca baş harflerden oluşmalıdır', () {
      expect(ProhibitedContentFilter.isValidPatientInitials('A.Y.'), isTrue);
      expect(ProhibitedContentFilter.isValidPatientInitials('M.K.A.'), isTrue);
      expect(
        ProhibitedContentFilter.isValidPatientInitials('Ahmet Yılmaz'),
        isFalse,
      );
    });

    test('Kullanıcı başına aktif talep limiti (Remote Config) aşıldığında hata döner', () async {
      final rc = FirebaseRemoteConfigService();
      final repo = FirestoreBloodRequestRepository(
        remoteConfig: rc,
        seedRequests: const <BloodRequest>[],
      );
      final now = DateTime.now().toUtc();
      const hosp = Hospital(
        id: 'h1',
        name: 'Ankara Şehir Hastanesi',
        province: 'Ankara',
        district: 'Çankaya',
        latitude: 39.9,
        longitude: 32.7,
      );

      for (int i = 0; i < rc.maxActiveRequestsPerUser; i++) {
        final res = await repo.createRequest(
          request: BloodRequest(
            id: 'r-$i',
            requesterUid: 'user-1',
            patientInitials: 'A.B.',
            bloodType: BloodType.aPos,
            productType: BloodProductType.wholeBlood,
            unitsNeeded: 1,
            hospital: hosp,
            department: 'Cerrahi',
            urgency: RequestUrgency.today,
            status: RequestStatus.open,
            createdAt: now,
            expiresAt: now.add(const Duration(hours: 24)),
          ),
          contactName: 'A.B.',
          contactPhone: '+905320000000',
        );
        expect(res.isSuccess, isTrue);
      }

      // Limit üstü (3. aktif talep) reddedilmeli
      final exceeded = await repo.createRequest(
        request: BloodRequest(
          id: 'r-exceeded',
          requesterUid: 'user-1',
          patientInitials: 'C.D.',
          bloodType: BloodType.aPos,
          productType: BloodProductType.wholeBlood,
          unitsNeeded: 1,
          hospital: hosp,
          department: 'Cerrahi',
          urgency: RequestUrgency.today,
          status: RequestStatus.open,
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 24)),
        ),
        contactName: 'C.D.',
        contactPhone: '+905320000000',
      );
      expect(exceeded.isFailure, isTrue);
    });

    test('Bağışçı teklifi -> Talep sahibi onayı -> Karşılıklı telefon açılması -> Bağış geçmişi kaydı', () async {
      final matchingRepo = FirestoreMatchingRepository();

      // 1. Bağışçı "Yardım edebilirim" der (pending, telefon kapalı)
      final offerRes = await matchingRepo.submitHelpOffer(
        requestId: 'req-test-1',
        donorUid: 'donor-99',
        donorDisplayName: 'Mehmet K.',
        donorBloodType: BloodType.aPos,
        timeSlot: DonationTimeSlot.morning,
      );
      final pendingOffer = offerRes.when(
        success: (d) => d,
        failure: (_) => throw StateError('Beklenmeyen hata'),
      );
      expect(pendingOffer.isContactVisible, isFalse);
      expect(pendingOffer.requesterPhone, isNull);

      // 2. Talep sahibi bağışçıyı onaylar -> karşılıklı telefon numaraları açılır
      final approvedRes = await matchingRepo.approveDonorAndUnlockContacts(
        requestId: 'req-test-1',
        donorUid: 'donor-99',
      );
      final approvedOffer = approvedRes.when(
        success: (d) => d,
        failure: (_) => throw StateError('Beklenmeyen hata'),
      );
      expect(approvedOffer.isContactVisible, isTrue);
      expect(approvedOffer.requesterPhone, isNotNull);
      expect(approvedOffer.donorPhone, isNotNull);

      // 3. Talep sahibi bağışı onaylar -> bağış geçmişine yazılır
      await matchingRepo.confirmDonationAndRecordHistory(
        requestId: 'req-test-1',
        donorUid: 'donor-99',
        hospitalName: 'Ankara Bilkent Şehir Hastanesi',
      );
      expect(matchingRepo.confirmedDonationHistory, isNotEmpty);
      expect(
        matchingRepo.confirmedDonationHistory.first['donorUid'],
        equals('donor-99'),
      );
    });

    test('FCM payload üzerinden deep link rotası (/requests/:id) doğru çözümlenir', () {
      final route = FcmNotificationService.resolveRouteFromPayload({
        'requestId': 'req-seed-1',
      });
      expect(route, equals('/requests/req-seed-1'));
    });

    testWidgets(
      'RequestDetailScreen paylaşım kartını açar ve bağışçı Yardım Edebilirim teklifi verebilir',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const RequestDetailScreen(
              requestId: 'req-seed-1',
              donorBloodType: BloodType.aPos,
            ),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
              currentUserIdStateProvider.overrideWith((ref) => 'donor-user-1'),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Kan grubunuz bu talep ile uyumludur.'),
          findsOneWidget,
        );

        // Paylaşım kartını aç
        await tester.tap(find.byKey(const Key('share_request_button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('share_visual_card_boundary')), findsOneWidget);
        expect(
          find.textContaining('https://kanagi.org.tr/requests/req-seed-1'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'NotificationsScreen okundu/okunmadı filtresini ve tümünü okundu işaretlemeyi çalıştırır',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const NotificationsScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Acil A Rh(+) Eritrosit İhtiyacı'), findsOneWidget);

        await tester.tap(find.byKey(const Key('mark_all_read_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('filter_unread_only_chip')));
        await tester.pumpAndSettle();
        expect(find.text('Yeni bildiriminiz yok'), findsOneWidget);
      },
    );

    testWidgets(
      'CreateRequestWizardScreen tam ad girildiğinde yalnız baş harf uyarısı gösterir',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const CreateRequestWizardScreen(),
            overrides: [
              connectivityServiceProvider.overrideWithValue(
                _OnlineConnectivityService(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('request_initials_field')),
          'Ahmet Yılmaz',
        );
        final submitBtn = find.byKey(const Key('submit_request_button'));
        await tester.scrollUntilVisible(
          submitBtn,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(submitBtn);
        await tester.pump();

        expect(
          find.text(
            'Gizlilik gereği lütfen yalnızca baş harfleri girin (Örn: A.Y.).',
          ),
          findsOneWidget,
        );
      },
    );
  });
}

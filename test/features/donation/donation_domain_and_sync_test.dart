import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/donation/data/donation_availability_sync.dart';
import 'package:turkiye_kan_agi/features/donation/data/eligibility_questionnaire_source.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_interval_policy.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_reminder_service.dart';
import 'package:turkiye_kan_agi/features/donation/domain/eligibility_question.dart';
import 'package:turkiye_kan_agi/features/donation/domain/eligibility_survey.dart';
import 'package:turkiye_kan_agi/features/donation/domain/next_donation_calculator.dart';
import 'package:turkiye_kan_agi/features/matching/data/firestore_matching_repository.dart';
import 'package:turkiye_kan_agi/features/matching/domain/donation_offer.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

class FakeReminderService implements DonationReminderService {
  DateTime? scheduledEligibleAt;
  int cancelCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<Result<DateTime?>> scheduleNextDonationReminder({
    required DateTime eligibleAtUtc,
    required String title,
    required String body,
    int reminderHour = 10,
  }) async {
    scheduledEligibleAt = eligibleAtUtc;
    return Result.success(eligibleAtUtc);
  }

  @override
  Future<Result<void>> cancelNextDonationReminder() async {
    scheduledEligibleAt = null;
    cancelCalls++;
    return const Result.success(null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sonraki Bağış Tarihi, Otomatik Uygunluk ve Hatırlatıcı Senkronizasyonu', () {
    test(
      'Erkek (90 gün), kadın (120 gün) ve trombosit (48 saat) bekleme süreleri Remote Config üzerinden hesaplanır',
      () {
        final rc = FirebaseRemoteConfigService();
        final policy = DonationIntervalPolicy.fromRemoteConfig(rc);
        final donatedAt = DateTime.utc(2026, 10, 1, 10);

        final wholeBloodRecord = DonationRecord(
          id: 'r1',
          donatedAt: donatedAt,
          place: 'Kızılay Ankara',
          productType: BloodProductType.wholeBlood,
          source: DonationRecordSource.manual,
          createdAt: donatedAt,
        );

        final maleInfo = NextDonationCalculator.calculate(
          history: [wholeBloodRecord],
          gender: UserGender.male,
          policy: policy,
          nowUtc: DateTime.utc(2026, 11, 1, 10),
        );
        expect(maleInfo.isEligibleNow, isFalse);
        expect(
          maleInfo.nextEligibleAt,
          donatedAt.add(const Duration(days: 90)),
        );
        expect(maleInfo.remainingDays, 59);

        final femaleInfo = NextDonationCalculator.calculate(
          history: [wholeBloodRecord],
          gender: UserGender.female,
          policy: policy,
          nowUtc: DateTime.utc(2027, 1, 15, 10),
        );
        expect(femaleInfo.isEligibleNow, isFalse);
        expect(
          femaleInfo.nextEligibleAt,
          donatedAt.add(const Duration(days: 120)),
        );

        final plateletRecord = DonationRecord(
          id: 'r2',
          donatedAt: donatedAt,
          place: 'Hacettepe Kan Merkezi',
          productType: BloodProductType.platelet,
          source: DonationRecordSource.request,
          createdAt: donatedAt,
        );
        final plateletAfter24h = NextDonationCalculator.calculate(
          history: [plateletRecord],
          gender: UserGender.male,
          policy: policy,
          nowUtc: donatedAt.add(const Duration(hours: 24)),
        );
        expect(plateletAfter24h.isEligibleNow, isFalse);
        expect(plateletAfter24h.remaining.inHours, 24);

        final plateletAfter50h = NextDonationCalculator.calculate(
          history: [plateletRecord],
          gender: UserGender.male,
          policy: policy,
          nowUtc: donatedAt.add(const Duration(hours: 50)),
        );
        expect(plateletAfter50h.isEligibleNow, isTrue);
      },
    );

    test(
      'DonationAvailabilitySync bekleme süresinde uygunluğu otomatik kapatıp hatırlatıcı kurar, süre dolunca tekrar açar',
      () async {
        final donationRepo = FirestoreDonationRepository();
        final profileRepo = FirestoreProfileRepository(
          donationRepository: donationRepo,
        );
        final rc = FirebaseRemoteConfigService();
        final reminder = FakeReminderService();
        final sync = DonationAvailabilitySync(
          donationRepository: donationRepo,
          profileRepository: profileRepo,
          remoteConfig: rc,
          reminderService: reminder,
        );

        final now = DateTime.now().toUtc();
        await profileRepo.saveFullProfile(
          publicProfile: UserPublicProfile(
            uid: 'u1',
            displayName: 'Ali K.',
            useNickname: false,
            province: 'İstanbul',
            district: 'Kadıköy',
            isAvailableToDonate: true,
            updatedAt: now,
          ),
          sensitiveProfile: UserSensitiveProfile(
            fullName: 'Ali Kaya',
            birthDate: DateTime.utc(1990, 5, 1),
            gender: UserGender.male,
            weightKg: 75,
            bloodType: BloodType.aPos,
            updatedAt: now,
          ),
        );

        await donationRepo.addManualDonation(
          uid: 'u1',
          donatedAt: now.subtract(const Duration(days: 10)),
          place: 'Kızılay Kadıköy',
          productType: BloodProductType.wholeBlood,
        );

        final infoWaiting = await sync.syncForUser(
          uid: 'u1',
          reminderTitle: 'Hatırlatma',
          reminderBody: 'Tekrar bağış yapabilirsiniz',
          nowUtc: now,
        );
        expect(infoWaiting.isEligibleNow, isFalse);
        expect(reminder.scheduledEligibleAt, isNotNull);

        final pubWaiting = (await profileRepo.getPublicProfile('u1')).when(
          success: (p) => p,
          failure: (_) => null,
        );
        expect(pubWaiting?.isAvailableToDonate, isFalse);

        // 95 gün sonrasını simüle ettiğimizde otomatik olarak tekrar uygun duruma geçmeli
        final infoElapsed = await sync.syncForUser(
          uid: 'u1',
          reminderTitle: 'Hatırlatma',
          reminderBody: 'Tekrar bağış yapabilirsiniz',
          nowUtc: now.add(const Duration(days: 95)),
        );
        expect(infoElapsed.isEligibleNow, isTrue);
        expect(reminder.scheduledEligibleAt, isNull);

        final pubElapsed = (await profileRepo.getPublicProfile('u1')).when(
          success: (p) => p,
          failure: (_) => null,
        );
        expect(pubElapsed?.isAvailableToDonate, isTrue);
      },
    );

    test(
      'Talep akışında bağış onaylandığında geçmişe otomatik eklenir, manuel silinemez ve veri indirmeye dahil edilir',
      () async {
        final donationRepo = FirestoreDonationRepository();
        final profileRepo = FirestoreProfileRepository(
          donationRepository: donationRepo,
        );
        final matchingRepo = FirestoreMatchingRepository(
          donationRepository: donationRepo,
        );

        await matchingRepo.submitHelpOffer(
          requestId: 'req-100',
          donorUid: 'donor-100',
          donorDisplayName: 'Zeynep S.',
          donorBloodType: BloodType.oPos,
          timeSlot: DonationTimeSlot.morning,
        );
        await matchingRepo.confirmDonationAndRecordHistory(
          requestId: 'req-100',
          donorUid: 'donor-100',
          hospitalName: 'Ankara Şehir Hastanesi',
          productType: BloodProductType.platelet,
        );

        final history = (await donationRepo.getHistory('donor-100')).when(
          success: (l) => l,
          failure: (_) => const <DonationRecord>[],
        );
        expect(history.length, 1);
        expect(history.first.source, DonationRecordSource.request);
        expect(history.first.place, 'Ankara Şehir Hastanesi');
        expect(history.first.productType, BloodProductType.platelet);

        // Talep akışı kaydı manuel olarak silinemez
        final delRes = await donationRepo.deleteManualDonation(
          uid: 'donor-100',
          recordId: 'req-100',
        );
        expect(delRes.isFailure, isTrue);

        // JSON veri dışa aktarımında bağış geçmişi yer almalı
        final exported =
            (await profileRepo.exportUserDataJson('donor-100')).when(
          success: (s) => jsonDecode(s) as Map<String, dynamic>,
          failure: (_) => <String, dynamic>{},
        );
        final exportedHistory = exported['donationHistory'] as List<dynamic>;
        expect(exportedHistory.length, 1);
      },
    );

    test(
      'Ön kontrol anketi JSON üzerinden yüklenir, cinsiyete göre filtrelenir ve 3 sonuç tipini doğru hesaplar',
      () async {
        final rc = FirebaseRemoteConfigService();
        final source = EligibilityQuestionnaireSource(remoteConfig: rc);
        final qRes = await source.loadQuestionnaire();
        final questionnaire = qRes.when(
          success: (q) => q,
          failure: (_) => null,
        );
        expect(questionnaire, isNotNull);

        final maleQuestions = questionnaire!.questionsFor(UserGender.male);
        final femaleQuestions = questionnaire.questionsFor(UserGender.female);
        expect(
          maleQuestions.any((q) => q.id == 'pregnancy_breastfeeding'),
          isFalse,
        );
        expect(
          femaleQuestions.any((q) => q.id == 'pregnancy_breastfeeding'),
          isTrue,
        );

        final allNo = <String, SurveyAnswer>{
          for (final q in maleQuestions) q.id: SurveyAnswer.no,
        };
        expect(
          EligibilitySurveyEvaluator.evaluate(
            questions: maleQuestions,
            answers: allNo,
          ),
          SurveyOutcome.looksEligible,
        );

        final medYes = <String, SurveyAnswer>{
          ...allNo,
          'medication_use': SurveyAnswer.yes,
        };
        expect(
          EligibilitySurveyEvaluator.evaluate(
            questions: maleQuestions,
            answers: medYes,
          ),
          SurveyOutcome.unsure,
        );

        final tattooYes = <String, SurveyAnswer>{
          ...medYes,
          'tattoo_piercing': SurveyAnswer.yes,
        };
        expect(
          EligibilitySurveyEvaluator.evaluate(
            questions: maleQuestions,
            answers: tattooYes,
          ),
          SurveyOutcome.looksIneligible,
        );
      },
    );

    test(
      'Varsayılan kullanıcı için Talepler geri sayımı, Bağış sekmesi ve Profil bağış sayısı tek kaynaktan (24 gün / 3 bağış) tutarlı döner',
      () async {
        final donationRepo = FirestoreDonationRepository();
        final profileRepo = FirestoreProfileRepository(
          donationRepository: donationRepo,
        );
        final rc = FirebaseRemoteConfigService();
        final reminder = FakeReminderService();
        final sync = DonationAvailabilitySync(
          donationRepository: donationRepo,
          profileRepository: profileRepo,
          remoteConfig: rc,
          reminderService: reminder,
        );

        final history =
            (await donationRepo.getHistory('default-authenticated-user')).when(
          success: (l) => l,
          failure: (_) => const <DonationRecord>[],
        );
        expect(history.length, 3);

        final nextInfo = await sync.syncForUser(
          uid: 'default-authenticated-user',
          reminderTitle: 'Hatırlatma',
          reminderBody: 'Tekrar bağış yapabilirsiniz',
        );
        expect(nextInfo.isEligibleNow, isFalse);
        expect(nextInfo.remainingDays, 24);
      },
    );
  });
}

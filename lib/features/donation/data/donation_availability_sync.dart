import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/data/local_notification_reminder_service.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_availability_state.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_interval_policy.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_reminder_service.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/next_donation_calculator.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/profile_repository.dart';

/// Bağış geçmişi değiştiğinde veya uygulama açıldığında:
/// 1. Sonraki bağış tarihini ([NextDonationInfo]) hesaplar (Remote Config aralıkları ile).
/// 2. "Bağışa uygunum" (`isAvailableToDonate`) anahtarını otomatik günceller.
/// 3. Hatırlatıcı açıksa yerel bildirimi planlar veya iptal eder.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class DonationAvailabilitySync {
  DonationAvailabilitySync({
    required DonationRepository donationRepository,
    required ProfileRepository profileRepository,
    required RemoteConfigService remoteConfig,
    required DonationReminderService reminderService,
  })  : _donationRepository = donationRepository,
        _profileRepository = profileRepository,
        _remoteConfig = remoteConfig,
        _reminderService = reminderService;

  final DonationRepository _donationRepository;
  final ProfileRepository _profileRepository;
  final RemoteConfigService _remoteConfig;
  final DonationReminderService _reminderService;

  Future<NextDonationInfo> syncForUser({
    required String uid,
    required String reminderTitle,
    required String reminderBody,
    DateTime? nowUtc,
  }) async {
    final effectiveNow = nowUtc ?? DateTime.now().toUtc();
    final history = (await _donationRepository.getHistory(uid)).when(
      success: (list) => list,
      failure: (_) => const <DonationRecord>[],
    );
    final sensitive =
        (await _profileRepository.getSensitiveProfile(uid)).when(
      success: (p) => p,
      failure: (_) => null,
    );
    final publicProfile =
        (await _profileRepository.getPublicProfile(uid)).when(
      success: (p) => p,
      failure: (_) => null,
    );
    final statusState =
        (await _donationRepository.getAvailabilityState(uid)).when(
      success: (s) => s,
      failure: (_) => const DonationAvailabilityState(),
    );

    final gender = sensitive?.gender ?? UserGender.unspecified;
    final policy = DonationIntervalPolicy.fromRemoteConfig(_remoteConfig);
    final nextInfo = NextDonationCalculator.calculate(
      history: history,
      gender: gender,
      policy: policy,
      nowUtc: effectiveNow,
    );

    final currentAvailable = publicProfile?.isAvailableToDonate ?? true;
    final decision = AvailabilityAutoUpdater.decide(
      isEligibleNow: nextInfo.isEligibleNow,
      isAvailable: currentAvailable,
      autoPaused: statusState.autoPaused,
    );

    if (decision.newIsAvailable != currentAvailable) {
      await _profileRepository.updateAvailability(
        uid: uid,
        isAvailable: decision.newIsAvailable,
      );
    }

    final updatedStatus = DonationAvailabilityState(
      autoPaused: decision.newAutoPaused,
      reminderEnabled: statusState.reminderEnabled,
      nextEligibleAt: nextInfo.nextEligibleAt,
    );
    await _donationRepository.saveAvailabilityState(
      uid: uid,
      state: updatedStatus,
    );

    if (updatedStatus.reminderEnabled &&
        !nextInfo.isEligibleNow &&
        nextInfo.nextEligibleAt != null) {
      int reminderHour = 10;
      try {
        reminderHour = _remoteConfig.donationReminderHour;
      } catch (_) {}
      await _reminderService.scheduleNextDonationReminder(
        eligibleAtUtc: nextInfo.nextEligibleAt!,
        title: reminderTitle,
        body: reminderBody,
        reminderHour: reminderHour,
      );
    } else {
      await _reminderService.cancelNextDonationReminder();
    }

    return nextInfo;
  }
}

final donationAvailabilitySyncProvider =
    Provider<DonationAvailabilitySync>((ref) {
  return DonationAvailabilitySync(
    donationRepository: ref.watch(donationRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    remoteConfig: ref.watch(remoteConfigServiceProvider),
    reminderService: ref.watch(donationReminderServiceProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/location_service.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_availability_state.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_interval_policy.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/donation/domain/next_donation_calculator.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';

/// Uygulama genelinde (Talepler üst kartı, Bağış sekmesi, Ön Kontrol Anketi,
/// Harita "Kan grubum" filtresi ve Profil kimlik kartı) kullanılan
/// tek doğruluk kaynağı (Single Source of Truth) anlık durum modeli.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class DonorStatusSnapshot {
  const DonorStatusSnapshot({
    required this.uid,
    required this.fullName,
    required this.displayName,
    required this.phoneNumber,
    required this.province,
    required this.district,
    required this.bloodType,
    required this.gender,
    required this.weightKg,
    required this.isAvailableToDonate,
    required this.history,
    required this.nextDonationInfo,
    required this.availabilityState,
    this.publicProfile,
    this.sensitiveProfile,
  });

  final String uid;
  final String fullName;
  final String displayName;
  final String phoneNumber;
  final String province;
  final String district;
  final BloodType bloodType;
  final UserGender gender;
  final int weightKg;
  final bool isAvailableToDonate;
  final List<DonationRecord> history;
  final NextDonationInfo nextDonationInfo;
  final DonationAvailabilityState availabilityState;
  final UserPublicProfile? publicProfile;
  final UserSensitiveProfile? sensitiveProfile;

  int get totalDonations => history.length;
  bool get isEligibleNow => nextDonationInfo.isEligibleNow;
  int get remainingDays => nextDonationInfo.remainingDays;
}

/// Bağış geçmişi veya uygunluk durumu güncellendiğinde tüm ekranların
/// anında yeniden hesaplama yapmasını sağlayan revizyon sayacı.
final donationRevisionProvider = StateProvider<int>((ref) => 0);

/// Tüm ekranların aynı kullanıcı profilini, kan grubunu, bağış sayısını
/// ve kalan bekleme gününü okumasını sağlayan merkezi sağlayıcı.
final currentDonorStatusProvider =
    FutureProvider<DonorStatusSnapshot>((ref) async {
  ref.watch(profileRevisionProvider);
  ref.watch(donationRevisionProvider);
  final gpsLoc = LocationService.isFlutterTest
      ? null
      : ref.watch(userLocationProvider).valueOrNull;
  final uid = ref.watch(currentUserIdStateProvider) ?? 'local-user';
  final profileRepo = ref.watch(profileRepositoryProvider);
  final donationRepo = ref.watch(donationRepositoryProvider);
  // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
  final remoteConfig = ref.watch(remoteConfigServiceProvider);

  final pubRes = await profileRepo.getPublicProfile(uid);
  final senRes = await profileRepo.getSensitiveProfile(uid);
  final histRes = await donationRepo.getHistory(uid);
  final availRes = await donationRepo.getAvailabilityState(uid);

  final pub = pubRes.when(success: (p) => p, failure: (_) => null);
  final sen = senRes.when(success: (s) => s, failure: (_) => null);
  final history = histRes.when(
    success: (list) => list,
    failure: (_) => const <DonationRecord>[],
  );
  final availState = availRes.when(
    success: (s) => s,
    failure: (_) => const DonationAvailabilityState(),
  );

  final gender = sen?.gender ?? UserGender.male;
  final policy = DonationIntervalPolicy.fromRemoteConfig(remoteConfig);
  final nextInfo = NextDonationCalculator.calculate(
    history: history,
    gender: gender,
    policy: policy,
    nowUtc: DateTime.now().toUtc(),
  );

  final fullName = (sen?.fullName.isNotEmpty == true)
      ? sen!.fullName
      : ((pub?.displayName.isNotEmpty == true)
          ? pub!.displayName
          : 'Ahmet Kaya');
  final displayName = (pub?.displayName.isNotEmpty == true)
      ? pub!.displayName
      : fullName;
  final phone = (sen?.phoneNumber != null && sen!.phoneNumber!.isNotEmpty)
      ? sen.phoneNumber!
      : '+90 532 ••• •• 48';
  final province = (pub?.province.isNotEmpty == true)
      ? pub!.province
      : (gpsLoc?.province ?? 'Ankara');
  final district = (pub?.district.isNotEmpty == true)
      ? pub!.district
      : (gpsLoc?.district ?? 'Çankaya');
  final bloodType = sen?.bloodType ?? BloodType.aPos;
  final weightKg = sen?.weightKg ?? 76;
  final isAvailable = pub?.isAvailableToDonate ?? nextInfo.isEligibleNow;

  return DonorStatusSnapshot(
    uid: uid,
    fullName: fullName,
    displayName: displayName,
    phoneNumber: phone,
    province: province,
    district: district,
    bloodType: bloodType,
    gender: gender,
    weightKg: weightKg,
    isAvailableToDonate: isAvailable,
    history: history,
    nextDonationInfo: nextInfo,
    availabilityState: availState,
    publicProfile: pub,
    sensitiveProfile: sen,
  );
});

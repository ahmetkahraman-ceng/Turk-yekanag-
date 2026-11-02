import 'package:turkiye_kan_agi/features/donation/domain/donation_interval_policy.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

/// Sonraki bağış uygunluk bilgisi.
class NextDonationInfo {
  const NextDonationInfo({
    required this.isEligibleNow,
    required this.remaining,
    this.nextEligibleAt,
    this.lastDonation,
  });

  /// Bekleme süresi dolmuş mu? (Tıbbi karar değildir; yalnızca süre hesabıdır.)
  final bool isEligibleNow;

  /// Hiç bağış yoksa `null`.
  final DateTime? nextEligibleAt;

  /// Kalan süre (uygunsa [Duration.zero]).
  final Duration remaining;

  final DonationRecord? lastDonation;

  int get remainingDays =>
      remaining == Duration.zero ? 0 : (remaining.inHours / 24).ceil();
}

/// Bağış geçmişinden bir sonraki uygun bağış tarihini hesaplayan saf fonksiyon.
///
/// Her geçmiş bağış için `bağışTarihi + beklemeSüresi(ürünTipi, cinsiyet)` hesaplanır
/// ve en geç tarih esas alınır (varsayım, RAPOR.md).
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
abstract final class NextDonationCalculator {
  static NextDonationInfo calculate({
    required List<DonationRecord> history,
    required UserGender gender,
    required DonationIntervalPolicy policy,
    required DateTime nowUtc,
  }) {
    if (history.isEmpty) {
      return const NextDonationInfo(
        isEligibleNow: true,
        remaining: Duration.zero,
      );
    }

    DateTime? latestEligible;
    DonationRecord? lastDonation;
    for (final record in history) {
      final eligibleAt = record.donatedAt.toUtc().add(
            policy.waitingPeriodAfter(
              donatedProduct: record.productType,
              gender: gender,
            ),
          );
      if (latestEligible == null || eligibleAt.isAfter(latestEligible)) {
        latestEligible = eligibleAt;
      }
      if (lastDonation == null ||
          record.donatedAt.isAfter(lastDonation.donatedAt)) {
        lastDonation = record;
      }
    }

    final next = latestEligible!;
    final isEligible = !nowUtc.isBefore(next);
    return NextDonationInfo(
      isEligibleNow: isEligible,
      nextEligibleAt: next,
      remaining: isEligible ? Duration.zero : next.difference(nowUtc),
      lastDonation: lastDonation,
    );
  }
}

import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_availability_state.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/donation/domain/eligibility_survey.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Bağış geçmişi, ön kontrol anketleri ve bağış durumu repository arayüzü.
/// Tüm veriler KVKK kapsamında özel nitelikli sağlık verisidir; UI doğrudan
/// Firebase'e erişmez, yalnızca bu arayüzü kullanır.
abstract class DonationRepository {
  Future<Result<List<DonationRecord>>> getHistory(String uid);

  /// Kullanıcının kendi eklediği bağış (gelecek tarihli olamaz).
  Future<Result<DonationRecord>> addManualDonation({
    required String uid,
    required DateTime donatedAt,
    required String place,
    required BloodProductType productType,
  });

  /// Yalnızca manuel kayıtlar silinebilir; talep akışı kayıtları korunur.
  Future<Result<void>> deleteManualDonation({
    required String uid,
    required String recordId,
  });

  /// Talep akışında bağış onaylandığında yerel önbelleğe kayıt ekler.
  /// Firestore'a yazımı güvenlik gereği Cloud Function (`onDonationOfferUpdated`) yapar.
  Future<Result<DonationRecord>> recordConfirmedRequestDonation({
    required String donorUid,
    required String requestId,
    required String place,
    required BloodProductType productType,
    required DateTime donatedAt,
  });

  Future<Result<void>> saveSurveyResult({
    required String uid,
    required EligibilitySurveyResult result,
  });

  Future<Result<List<EligibilitySurveyResult>>> getSurveyResults(String uid);

  Future<Result<DonationAvailabilityState>> getAvailabilityState(String uid);

  Future<Result<void>> saveAvailabilityState({
    required String uid,
    required DonationAvailabilityState state,
  });

  /// "Verilerimi indir" için bağış geçmişi + anket + durum verisi.
  Future<Result<Map<String, dynamic>>> exportDonationData(String uid);
}

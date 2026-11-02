import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/error/app_failure.dart';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/features/donation/data/firestore_donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_repository.dart';
import 'package:turkiye_kan_agi/features/matching/domain/donation_offer.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Eşleştirme, bağışçı adımları, saat koordinasyonu ve karşılıklı iletişim açma repository'si.
class FirestoreMatchingRepository {
  FirestoreMatchingRepository({
    FirebaseFirestore? firestore,
    DonationRepository? donationRepository,
  })  : _firestore = firestore,
        _donationRepository = donationRepository;

  final FirebaseFirestore? _firestore;
  final DonationRepository? _donationRepository;

  final Map<String, List<DonationOffer>> _offersByRequest =
      <String, List<DonationOffer>>{
    'req-seed-1': <DonationOffer>[
      DonationOffer(
        id: 'offer-seed-1',
        requestId: 'req-seed-1',
        donorUid: 'donor-seed-1',
        donorDisplayName: 'Ahmet T.',
        donorBloodType: BloodType.aPos,
        status: DonationOfferStatus.pending,
        timeSlot: DonationTimeSlot.immediate,
        createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 20)),
        quickMessage: 'Yola çıkmaya hazırım.',
      ),
    ],
  };

  final List<Map<String, dynamic>> _confirmedDonationHistory =
      <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get confirmedDonationHistory =>
      List.unmodifiable(_confirmedDonationHistory);

  Future<Result<List<DonationOffer>>> getOffersForRequest(
    String requestId,
  ) async {
    final list = _offersByRequest[requestId] ?? const <DonationOffer>[];
    return Result.success(List<DonationOffer>.unmodifiable(list));
  }

  /// Bağışçı "Yardım edebilirim" butonuna bastığında teklif oluşturur.
  /// Bu aşamada telefon numaraları AÇILMAZ (`pending`).
  Future<Result<DonationOffer>> submitHelpOffer({
    required String requestId,
    required String donorUid,
    required String donorDisplayName,
    required BloodType donorBloodType,
    required DonationTimeSlot timeSlot,
    String quickMessage = '',
  }) async {
    final currentList = List<DonationOffer>.of(
      _offersByRequest[requestId] ?? const <DonationOffer>[],
    );
    final existingIdx = currentList.indexWhere((o) => o.donorUid == donorUid);

    final offer = DonationOffer(
      id: 'offer-$requestId-$donorUid',
      requestId: requestId,
      donorUid: donorUid,
      donorDisplayName: donorDisplayName,
      donorBloodType: donorBloodType,
      status: DonationOfferStatus.pending,
      timeSlot: timeSlot,
      createdAt: DateTime.now().toUtc(),
      quickMessage: quickMessage,
    );

    if (existingIdx != -1) {
      currentList[existingIdx] = offer;
    } else {
      currentList.insert(0, offer);
    }
    _offersByRequest[requestId] = currentList;

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('blood_requests')
            .doc(requestId)
            .collection('offers')
            .doc(donorUid)
            .set(<String, dynamic>{
          'id': offer.id,
          'requestId': requestId,
          'donorUid': donorUid,
          'donorDisplayName': donorDisplayName,
          'donorBloodType': donorBloodType.code,
          'status': offer.status.code,
          'timeSlot': timeSlot.code,
          'quickMessage': quickMessage,
          'createdAt': offer.createdAt.toIso8601String(),
        });
      } catch (_) {}
    }

    return Result.success(offer);
  }

  /// Talep sahibi bağışçıyı onayladığında (`approved`) karşılıklı telefon numaralarını açar.
  Future<Result<DonationOffer>> approveDonorAndUnlockContacts({
    required String requestId,
    required String donorUid,
    String donorPhone = '+905321112233',
    String requesterPhone = '+905334445566',
  }) async {
    final currentList = List<DonationOffer>.of(
      _offersByRequest[requestId] ?? const <DonationOffer>[],
    );
    final idx = currentList.indexWhere((o) => o.donorUid == donorUid);
    if (idx == -1) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'OFFER_NOT_FOUND'),
      );
    }

    final updated = currentList[idx].copyWith(
      status: DonationOfferStatus.approved,
      donorPhone: donorPhone,
      requesterPhone: requesterPhone,
    );
    currentList[idx] = updated;
    _offersByRequest[requestId] = currentList;

    final fs = _firestore;
    if (fs != null) {
      try {
        final reqRef = fs.collection('blood_requests').doc(requestId);
        await reqRef.collection('offers').doc(donorUid).update(<String, dynamic>{
          'status': DonationOfferStatus.approved.code,
        });
        await reqRef
            .collection('mutual_contacts')
            .doc(donorUid)
            .set(<String, dynamic>{
          'donorUid': donorUid,
          'donorPhone': donorPhone,
          'requesterPhone': requesterPhone,
          'unlockedAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {}
    }

    return Result.success(updated);
  }

  /// Bağışçı durum adımlarını (`onTheWay`, `arrivedAtHospital`, `donatedPendingConfirmation`)
  /// ve hızlı mesajı günceller.
  Future<Result<DonationOffer>> updateDonorStep({
    required String requestId,
    required String donorUid,
    required DonationOfferStatus nextStatus,
    String? quickMessage,
  }) async {
    final currentList = List<DonationOffer>.of(
      _offersByRequest[requestId] ?? const <DonationOffer>[],
    );
    final idx = currentList.indexWhere((o) => o.donorUid == donorUid);
    if (idx == -1) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'OFFER_NOT_FOUND'),
      );
    }

    final updated = currentList[idx].copyWith(
      status: nextStatus,
      quickMessage: quickMessage ?? currentList[idx].quickMessage,
    );
    currentList[idx] = updated;
    _offersByRequest[requestId] = currentList;
    return Result.success(updated);
  }

  /// Talep sahibi bağışı onaylar (`confirmed`) ve bağış geçmişine otomatik yazar.
  Future<Result<DonationOffer>> confirmDonationAndRecordHistory({
    required String requestId,
    required String donorUid,
    required String hospitalName,
    BloodProductType productType = BloodProductType.wholeBlood,
  }) async {
    final currentList = List<DonationOffer>.of(
      _offersByRequest[requestId] ?? const <DonationOffer>[],
    );
    final idx = currentList.indexWhere((o) => o.donorUid == donorUid);
    if (idx == -1) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'OFFER_NOT_FOUND'),
      );
    }

    final updated = currentList[idx].copyWith(
      status: DonationOfferStatus.confirmed,
    );
    currentList[idx] = updated;
    _offersByRequest[requestId] = currentList;

    final nowUtc = DateTime.now().toUtc();
    final record = <String, dynamic>{
      'requestId': requestId,
      'donorUid': donorUid,
      'hospitalName': hospitalName,
      'place': hospitalName,
      'productType': productType.code,
      'source': 'request',
      'donatedAt': nowUtc.toIso8601String(),
      'confirmedAt': nowUtc.toIso8601String(),
    };
    _confirmedDonationHistory.add(record);

    await _donationRepository?.recordConfirmedRequestDonation(
      donorUid: donorUid,
      requestId: requestId,
      place: hospitalName,
      productType: productType,
      donatedAt: nowUtc,
    );

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('blood_requests')
            .doc(requestId)
            .collection('offers')
            .doc(donorUid)
            .update(<String, dynamic>{
          'status': DonationOfferStatus.confirmed.code,
        });
      } catch (_) {}
    }

    return Result.success(updated);
  }
}

final matchingRepositoryProvider = Provider<FirestoreMatchingRepository>((ref) {
  final donationRepo = ref.watch(donationRepositoryProvider);
  return FirestoreMatchingRepository(donationRepository: donationRepo);
});

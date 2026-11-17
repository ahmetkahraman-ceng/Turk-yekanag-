import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/error/app_failure.dart';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/core/mock/mock_data.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_availability_state.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/eligibility_survey.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Firestore tabanlı bağış geçmişi, sağlık anketi ve bağış durumu repository'si.
///
/// Koleksiyonlar:
/// - `users/{uid}/donation_history/{id}` (KVKK özel nitelikli sağlık verisi)
/// - `users/{uid}/health_surveys/{id}` (KVKK özel nitelikli sağlık verisi)
/// - `users/{uid}/private_data/donation_status`
class FirestoreDonationRepository implements DonationRepository {
  FirestoreDonationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore {
    _seedDefaultHistory();
  }

  final FirebaseFirestore? _firestore;

  final Map<String, List<DonationRecord>> _historyCache = {};
  final Map<String, List<EligibilitySurveyResult>> _surveyCache = {};
  final Map<String, DonationAvailabilityState> _statusCache = {};
  int _idSeq = 0;

  static const String historyCollection = 'donation_history';
  static const String surveysCollection = 'health_surveys';
  static const String privateCollection = 'private_data';
  static const String statusDocId = 'donation_status';

  static const Set<String> _seededUids = <String>{
    'local-user',
    'default-authenticated-user',
    'uid-google-user',
    'uid-apple-user',
  };

  void _seedDefaultHistory() {
    final samples = List<DonationRecord>.of(MockData.sampleDonations);
    final nextEligible =
        samples.first.donatedAt.toUtc().add(const Duration(days: 90));
    final initialStatus = DonationAvailabilityState(
      autoPaused: true,
      reminderEnabled: true,
      nextEligibleAt: nextEligible,
    );
    for (final uid in _seededUids) {
      _historyCache[uid] = List<DonationRecord>.of(samples);
      _statusCache[uid] = initialStatus;
    }
  }

  bool _isSeededOrAuthDevUid(String uid) =>
      _seededUids.contains(uid) || uid.startsWith('uid-');

  List<DonationRecord> _resolveHistoryFor(String uid) {
    final existing = _historyCache[uid];
    if (existing != null) return existing;
    if (uid.startsWith('uid-')) {
      final seeded = List<DonationRecord>.of(
        _historyCache['local-user'] ?? MockData.sampleDonations,
      );
      _historyCache[uid] = seeded;
      return seeded;
    }
    return const <DonationRecord>[];
  }

  @override
  Future<Result<List<DonationRecord>>> getHistory(String uid) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final snap = await fs
            .collection('users')
            .doc(uid)
            .collection(historyCollection)
            .orderBy('donatedAt', descending: true)
            .get();
        final list = snap.docs
            .map((d) => DonationRecord.fromJson(d.id, d.data()))
            .toList(growable: false);
        _historyCache[uid] = List<DonationRecord>.of(list);
        return Result.success(list);
      } catch (_) {}
    }
    final cached = List<DonationRecord>.of(_resolveHistoryFor(uid));
    cached.sort((a, b) => b.donatedAt.compareTo(a.donatedAt));
    return Result.success(List<DonationRecord>.unmodifiable(cached));
  }

  @override
  Future<Result<DonationRecord>> addManualDonation({
    required String uid,
    required DateTime donatedAt,
    required String place,
    required BloodProductType productType,
  }) async {
    final trimmedPlace = place.trim();
    if (trimmedPlace.isEmpty || trimmedPlace.length > 160) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'INVALID_DONATION_PLACE'),
      );
    }
    final nowUtc = DateTime.now().toUtc();
    final donatedUtc = donatedAt.toUtc();
    if (donatedUtc.isAfter(nowUtc.add(const Duration(minutes: 5)))) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'FUTURE_DONATION_DATE'),
      );
    }

    _idSeq++;
    final id = 'manual-${nowUtc.millisecondsSinceEpoch}-$_idSeq';
    final record = DonationRecord(
      id: id,
      donatedAt: donatedUtc,
      place: trimmedPlace,
      productType: productType,
      source: DonationRecordSource.manual,
      createdAt: nowUtc,
    );

    final list = List<DonationRecord>.of(_resolveHistoryFor(uid));
    list.insert(0, record);
    _historyCache[uid] = list;
    if (_isSeededOrAuthDevUid(uid)) {
      for (final sUid in _seededUids) {
        _historyCache[sUid] = List<DonationRecord>.of(list);
      }
    }

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection(historyCollection)
            .doc(id)
            .set(record.toJson());
      } catch (_) {}
    }
    return Result.success(record);
  }

  @override
  Future<Result<void>> deleteManualDonation({
    required String uid,
    required String recordId,
  }) async {
    final list = List<DonationRecord>.of(_resolveHistoryFor(uid));
    final idx = list.indexWhere((r) => r.id == recordId);
    if (idx != -1 && list[idx].source == DonationRecordSource.request) {
      return const Result.failure(
        AppFailure.unauthorized(technicalDetails: 'CANNOT_DELETE_REQUEST_RECORD'),
      );
    }
    list.removeWhere((r) => r.id == recordId);
    _historyCache[uid] = list;
    if (_isSeededOrAuthDevUid(uid)) {
      for (final sUid in _seededUids) {
        _historyCache[sUid] = List<DonationRecord>.of(list);
      }
    }

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection(historyCollection)
            .doc(recordId)
            .delete();
      } catch (_) {}
    }
    return const Result.success(null);
  }

  @override
  Future<Result<DonationRecord>> recordConfirmedRequestDonation({
    required String donorUid,
    required String requestId,
    required String place,
    required BloodProductType productType,
    required DateTime donatedAt,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    final record = DonationRecord(
      id: requestId,
      donatedAt: donatedAt.toUtc(),
      place: place.trim(),
      productType: productType,
      source: DonationRecordSource.request,
      requestId: requestId,
      createdAt: nowUtc,
    );

    final list = List<DonationRecord>.of(_resolveHistoryFor(donorUid));
    list.removeWhere((r) => r.id == requestId || r.requestId == requestId);
    list.insert(0, record);
    _historyCache[donorUid] = list;
    if (_isSeededOrAuthDevUid(donorUid)) {
      for (final sUid in _seededUids) {
        _historyCache[sUid] = List<DonationRecord>.of(list);
      }
    }

    // Not: Firestore'da `source == 'request'` kayıtlarını yalnızca Cloud Function
    // (`onDonationOfferUpdated`) yazabilir; istemci doğrudan yazmaya çalışmaz.
    return Result.success(record);
  }

  @override
  Future<Result<void>> saveSurveyResult({
    required String uid,
    required EligibilitySurveyResult result,
  }) async {
    final list = List<EligibilitySurveyResult>.of(_surveyCache[uid] ?? const []);
    list.insert(0, result);
    _surveyCache[uid] = list;

    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection(surveysCollection)
            .doc(result.id)
            .set(result.toJson());
      } catch (_) {}
    }
    return const Result.success(null);
  }

  @override
  Future<Result<List<EligibilitySurveyResult>>> getSurveyResults(
    String uid,
  ) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final snap = await fs
            .collection('users')
            .doc(uid)
            .collection(surveysCollection)
            .orderBy('completedAt', descending: true)
            .get();
        final list = snap.docs
            .map((d) => EligibilitySurveyResult.fromJson(d.id, d.data()))
            .toList(growable: false);
        _surveyCache[uid] = List<EligibilitySurveyResult>.of(list);
        return Result.success(list);
      } catch (_) {}
    }
    return Result.success(
      List<EligibilitySurveyResult>.unmodifiable(_surveyCache[uid] ?? const []),
    );
  }

  @override
  Future<Result<DonationAvailabilityState>> getAvailabilityState(
    String uid,
  ) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final doc = await fs
            .collection('users')
            .doc(uid)
            .collection(privateCollection)
            .doc(statusDocId)
            .get();
        if (doc.exists && doc.data() != null) {
          final parsed = DonationAvailabilityState.fromJson(doc.data()!);
          _statusCache[uid] = parsed;
          return Result.success(parsed);
        }
      } catch (_) {}
    }
    final state = _statusCache[uid] ??
        (uid.startsWith('uid-') ? _statusCache['local-user'] : null) ??
        const DonationAvailabilityState();
    return Result.success(state);
  }

  @override
  Future<Result<void>> saveAvailabilityState({
    required String uid,
    required DonationAvailabilityState state,
  }) async {
    _statusCache[uid] = state;
    if (_isSeededOrAuthDevUid(uid)) {
      for (final sUid in _seededUids) {
        _statusCache[sUid] = state;
      }
    }
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection(privateCollection)
            .doc(statusDocId)
            .set(state.toJson());
      } catch (_) {}
    }
    return const Result.success(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> exportDonationData(String uid) async {
    final history = (await getHistory(uid)).when(
      success: (list) => list.map((e) => {'id': e.id, ...e.toJson()}).toList(),
      failure: (_) => const <Map<String, dynamic>>[],
    );
    final surveys = (await getSurveyResults(uid)).when(
      success: (list) => list.map((e) => {'id': e.id, ...e.toJson()}).toList(),
      failure: (_) => const <Map<String, dynamic>>[],
    );
    final status = (await getAvailabilityState(uid)).when(
      success: (s) => s.toJson(),
      failure: (_) => null,
    );
    return Result.success(<String, dynamic>{
      'donationHistory': history,
      'healthSurveys': surveys,
      'donationStatus': status,
    });
  }
}

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return FirestoreDonationRepository();
});

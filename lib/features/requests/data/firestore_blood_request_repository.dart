import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/error/app_failure.dart';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/hospital.dart';
import 'package:turkiye_kan_agi/features/requests/domain/prohibited_content_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Firestore ve Storage tabanlı kan talebi repository uygulaması.
class FirestoreBloodRequestRepository implements BloodRequestRepository {
  FirestoreBloodRequestRepository({
    required RemoteConfigService remoteConfig,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    List<BloodRequest>? seedRequests,
  })  : _remoteConfig = remoteConfig,
        _firestore = firestore,
        _storage = storage,
        _memoryStore = List<BloodRequest>.of(seedRequests ?? _defaultSeeds());

  final RemoteConfigService _remoteConfig;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final List<BloodRequest> _memoryStore;

  static List<BloodRequest> _defaultSeeds() {
    final now = DateTime.now().toUtc();
    return <BloodRequest>[
      BloodRequest(
        id: 'req-seed-1',
        requesterUid: 'seed-owner-1',
        patientInitials: 'M.K.',
        bloodType: BloodType.aPos,
        productType: BloodProductType.erythrocyte,
        unitsNeeded: 2,
        hospital: const Hospital(
          id: 'hosp-ank-bilkent',
          name: 'Ankara Bilkent Şehir Hastanesi',
          province: 'Ankara',
          district: 'Çankaya',
          latitude: 39.9008,
          longitude: 32.7556,
        ),
        department: 'Genel Yoğun Bakım',
        urgency: RequestUrgency.critical,
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(hours: 23)),
        notes: 'Ameliyat hazırlığı için acil eritrosit süspansiyonu ihtiyacı.',
        offerCount: 1,
      ),
      BloodRequest(
        id: 'req-seed-2',
        requesterUid: 'seed-owner-2',
        patientInitials: 'S.Y.',
        bloodType: BloodType.oNeg,
        productType: BloodProductType.platelet,
        unitsNeeded: 1,
        hospital: const Hospital(
          id: 'hosp-ist-capa',
          name: 'İstanbul Üniversitesi İstanbul Tıp Fakültesi (Çapa)',
          province: 'İstanbul',
          district: 'Fatih',
          latitude: 41.0156,
          longitude: 28.9329,
        ),
        department: 'Erişkin Hematoloji Servisi',
        urgency: RequestUrgency.today,
        status: RequestStatus.open,
        createdAt: now.subtract(const Duration(hours: 3)),
        expiresAt: now.add(const Duration(hours: 45)),
        notes: 'Aferez trombosit ihtiyacı bulunmaktadır.',
        offerCount: 2,
      ),
    ];
  }

  @override
  Future<Result<List<BloodRequest>>> fetchRequests({
    BloodRequestFilter filter = const BloodRequestFilter(),
    int limit = 10,
    int offset = 0,
  }) async {
    final filtered = _memoryStore.where((req) {
      if (filter.bloodType != null && req.bloodType != filter.bloodType) {
        return false;
      }
      if (filter.productType != null && req.productType != filter.productType) {
        return false;
      }
      if (filter.province != null &&
          req.hospital.province != filter.province) {
        return false;
      }
      if (filter.district != null &&
          req.hospital.district != filter.district) {
        return false;
      }
      if (filter.urgency != null && req.urgency != filter.urgency) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      final urgencyCmp = b.urgency.priorityWeight.compareTo(
        a.urgency.priorityWeight,
      );
      if (urgencyCmp != 0) return urgencyCmp;
      return b.createdAt.compareTo(a.createdAt);
    });

    if (offset >= filtered.length) {
      return const Result.success(<BloodRequest>[]);
    }
    final end = (offset + limit).clamp(0, filtered.length);
    return Result.success(filtered.sublist(offset, end));
  }

  @override
  Future<Result<BloodRequest?>> getRequestById(String requestId) async {
    final found = _memoryStore.where((r) => r.id == requestId).firstOrNull;
    return Result.success(found);
  }

  @override
  Future<Result<BloodRequest>> createRequest({
    required BloodRequest request,
    required String contactName,
    required String contactPhone,
    Uint8List? medicalReportBytes,
  }) async {
    if (ProhibitedContentFilter.containsProhibitedContent(request.notes) ||
        ProhibitedContentFilter.containsProhibitedContent(request.department)) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'PROHIBITED_CONTENT'),
      );
    }

    final now = DateTime.now().toUtc();
    final activeByUser = _memoryStore.where(
      (r) =>
          r.requesterUid == request.requesterUid &&
          r.status == RequestStatus.open,
    );
    if (activeByUser.length >= _remoteConfig.maxActiveRequestsPerUser) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'MAX_ACTIVE_LIMIT'),
      );
    }

    final todayByUser = _memoryStore.where(
      (r) =>
          r.requesterUid == request.requesterUid &&
          now.difference(r.createdAt).inHours < 24,
    );
    if (todayByUser.length >= _remoteConfig.maxDailyRequestsPerUser) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'MAX_DAILY_LIMIT'),
      );
    }

    final finalReq = request.copyWith(
      hasMedicalReport:
          medicalReportBytes != null || request.hasMedicalReport,
    );
    _memoryStore.insert(0, finalReq);

    final fs = _firestore;
    if (fs != null) {
      try {
        final docRef = fs.collection('blood_requests').doc(finalReq.id);
        final batch = fs.batch();
        batch.set(docRef, finalReq.toJson());
        batch.set(
          docRef.collection('private_contact').doc('info'),
          <String, dynamic>{
            'contactName': contactName,
            'contactPhone': contactPhone,
            'updatedAt': now.toIso8601String(),
          },
        );
        await batch.commit();
      } catch (_) {}
    }

    final st = _storage;
    if (st != null && medicalReportBytes != null) {
      try {
        await st
            .ref('blood_requests/${finalReq.id}/medical_report.jpg')
            .putData(medicalReportBytes);
      } catch (_) {}
    }

    return Result.success(finalReq);
  }

  @override
  Future<Result<BloodRequest>> updateRequest(BloodRequest updated) async {
    if (ProhibitedContentFilter.containsProhibitedContent(updated.notes) ||
        ProhibitedContentFilter.containsProhibitedContent(updated.department)) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'PROHIBITED_CONTENT'),
      );
    }
    final idx = _memoryStore.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _memoryStore[idx] = updated;
    }
    return Result.success(updated);
  }

  @override
  Future<Result<BloodRequest>> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    final idx = _memoryStore.indexWhere((r) => r.id == requestId);
    if (idx == -1) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'NOT_FOUND'),
      );
    }
    final updated = _memoryStore[idx].copyWith(status: status);
    _memoryStore[idx] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<BloodRequest>> extendExpiry({
    required String requestId,
    Duration extensionDuration = const Duration(hours: 24),
  }) async {
    final idx = _memoryStore.indexWhere((r) => r.id == requestId);
    if (idx == -1) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'NOT_FOUND'),
      );
    }
    final current = _memoryStore[idx];
    final updated = current.copyWith(
      expiresAt: current.expiresAt.add(extensionDuration),
      status: RequestStatus.open,
    );
    _memoryStore[idx] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<BloodRequest>> toggleStopNewOffers({
    required String requestId,
    required bool stopNewOffers,
  }) async {
    final idx = _memoryStore.indexWhere((r) => r.id == requestId);
    if (idx == -1) {
      return const Result.failure(
        AppFailure.unexpected(technicalDetails: 'NOT_FOUND'),
      );
    }
    final updated = _memoryStore[idx].copyWith(stopNewOffers: stopNewOffers);
    _memoryStore[idx] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<void>> reportRequest({
    required String requestId,
    required String reporterUid,
    required String reason,
  }) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('request_reports').add(<String, dynamic>{
          'requestId': requestId,
          'reporterUid': reporterUid,
          'reason': reason,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {}
    }
    return const Result.success(null);
  }
}

final bloodRequestRepositoryProvider = Provider<BloodRequestRepository>((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  return FirestoreBloodRequestRepository(remoteConfig: remoteConfig);
});

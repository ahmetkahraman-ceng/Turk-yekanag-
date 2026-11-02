import 'dart:typed_data';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';

/// Kan talebi repository soyut arayüzü.
abstract class BloodRequestRepository {
  Future<Result<List<BloodRequest>>> fetchRequests({
    BloodRequestFilter filter = const BloodRequestFilter(),
    int limit = 10,
    int offset = 0,
  });

  Future<Result<BloodRequest?>> getRequestById(String requestId);

  Future<Result<BloodRequest>> createRequest({
    required BloodRequest request,
    required String contactName,
    required String contactPhone,
    Uint8List? medicalReportBytes,
  });

  Future<Result<BloodRequest>> updateRequest(BloodRequest updated);

  Future<Result<BloodRequest>> updateStatus({
    required String requestId,
    required RequestStatus status,
  });

  Future<Result<BloodRequest>> extendExpiry({
    required String requestId,
    Duration extensionDuration = const Duration(hours: 24),
  });

  Future<Result<BloodRequest>> toggleStopNewOffers({
    required String requestId,
    required bool stopNewOffers,
  });

  Future<Result<void>> reportRequest({
    required String requestId,
    required String reporterUid,
    required String reason,
  });
}

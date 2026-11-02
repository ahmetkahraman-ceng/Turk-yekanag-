import 'package:flutter/foundation.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/hospital.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Herkese açık kan talebi modeli (`blood_requests/{requestId}`).
/// KVKK ve güvenlik kuralı: Hasta yakını telefon numarası burada YER ALMAZ,
/// `blood_requests/{requestId}/private_contact/info` alt dokümanında tutulur.
@immutable
class BloodRequest {
  const BloodRequest({
    required this.id,
    required this.requesterUid,
    required this.patientInitials,
    required this.bloodType,
    required this.productType,
    required this.unitsNeeded,
    required this.hospital,
    required this.department,
    required this.urgency,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.notes = '',
    this.offerCount = 0,
    this.stopNewOffers = false,
    this.hasMedicalReport = false,
  });

  final String id;
  final String requesterUid;
  final String patientInitials;
  final BloodType bloodType;
  final BloodProductType productType;
  final int unitsNeeded;
  final Hospital hospital;
  final String department;
  final RequestUrgency urgency;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String notes;
  final int offerCount;
  final bool stopNewOffers;
  final bool hasMedicalReport;

  String get deepLinkUrl => 'https://kanagi.org.tr/requests/$id';

  BloodRequest copyWith({
    String? patientInitials,
    BloodType? bloodType,
    BloodProductType? productType,
    int? unitsNeeded,
    Hospital? hospital,
    String? department,
    RequestUrgency? urgency,
    RequestStatus? status,
    DateTime? expiresAt,
    String? notes,
    int? offerCount,
    bool? stopNewOffers,
    bool? hasMedicalReport,
  }) {
    return BloodRequest(
      id: id,
      requesterUid: requesterUid,
      patientInitials: patientInitials ?? this.patientInitials,
      bloodType: bloodType ?? this.bloodType,
      productType: productType ?? this.productType,
      unitsNeeded: unitsNeeded ?? this.unitsNeeded,
      hospital: hospital ?? this.hospital,
      department: department ?? this.department,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      notes: notes ?? this.notes,
      offerCount: offerCount ?? this.offerCount,
      stopNewOffers: stopNewOffers ?? this.stopNewOffers,
      hasMedicalReport: hasMedicalReport ?? this.hasMedicalReport,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'requesterUid': requesterUid,
      'patientInitials': patientInitials,
      'bloodType': bloodType.code,
      'productType': productType.code,
      'unitsNeeded': unitsNeeded,
      'hospital': hospital.toJson(),
      'province': hospital.province,
      'district': hospital.district,
      'department': department,
      'urgency': urgency.code,
      'status': status.code,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'notes': notes,
      'offerCount': offerCount,
      'stopNewOffers': stopNewOffers,
      'hasMedicalReport': hasMedicalReport,
    };
  }

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: (json['id'] as String?) ?? '',
      requesterUid: (json['requesterUid'] as String?) ?? '',
      patientInitials: (json['patientInitials'] as String?) ?? 'H.A.',
      bloodType: BloodType.fromCode(json['bloodType'] as String?),
      productType: BloodProductType.fromCode(json['productType'] as String?),
      unitsNeeded: (json['unitsNeeded'] as num?)?.toInt() ?? 1,
      hospital: Hospital.fromJson(
        (json['hospital'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      department: (json['department'] as String?) ?? '',
      urgency: RequestUrgency.fromCode(json['urgency'] as String?),
      status: RequestStatus.fromCode(json['status'] as String?),
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      expiresAt: DateTime.tryParse((json['expiresAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      notes: (json['notes'] as String?) ?? '',
      offerCount: (json['offerCount'] as num?)?.toInt() ?? 0,
      stopNewOffers: (json['stopNewOffers'] as bool?) ?? false,
      hasMedicalReport: (json['hasMedicalReport'] as bool?) ?? false,
    );
  }
}

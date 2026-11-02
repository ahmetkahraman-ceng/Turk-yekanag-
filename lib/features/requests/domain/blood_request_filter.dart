import 'package:flutter/foundation.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Talep listesi filtreleme modeli.
@immutable
class BloodRequestFilter {
  const BloodRequestFilter({
    this.bloodType,
    this.productType,
    this.province,
    this.district,
    this.urgency,
  });

  final BloodType? bloodType;
  final BloodProductType? productType;
  final String? province;
  final String? district;
  final RequestUrgency? urgency;

  bool get hasAnyFilter =>
      bloodType != null ||
      productType != null ||
      province != null ||
      district != null ||
      urgency != null;

  BloodRequestFilter copyWith({
    BloodType? bloodType,
    bool clearBloodType = false,
    BloodProductType? productType,
    bool clearProductType = false,
    String? province,
    bool clearProvince = false,
    String? district,
    bool clearDistrict = false,
    RequestUrgency? urgency,
    bool clearUrgency = false,
  }) {
    return BloodRequestFilter(
      bloodType: clearBloodType ? null : (bloodType ?? this.bloodType),
      productType: clearProductType ? null : (productType ?? this.productType),
      province: clearProvince ? null : (province ?? this.province),
      district: clearDistrict ? null : (district ?? this.district),
      urgency: clearUrgency ? null : (urgency ?? this.urgency),
    );
  }
}

import 'package:flutter/foundation.dart';

/// Kan bağış merkezi ve gezici bağış aracı modeli.
@immutable
class DonationCenter {
  const DonationCenter({
    required this.id,
    required this.name,
    required this.province,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.workingHours,
    required this.phone,
    this.isOpenNow = true,
    this.isMobileUnit = false,
    this.distanceKm = 2.4,
  });

  final String id;
  final String name;
  final String province;
  final String district;
  final double latitude;
  final double longitude;
  final String workingHours;
  final String phone;
  final bool isOpenNow;
  final bool isMobileUnit;
  final double distanceKm;
}

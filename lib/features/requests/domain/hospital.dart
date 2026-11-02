import 'package:flutter/foundation.dart';

/// Hastane modeli (yerel JSON ve ileride Places API ile uyumlu).
@immutable
class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    required this.province,
    required this.district,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String province;
  final String district;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'province': province,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      province: (json['province'] as String?) ?? '',
      district: (json['district'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 39.9208,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 32.8541,
    );
  }
}

/// Hastane veri kaynağı arayüzü.
/// İlk aşamada yerel JSON'dan çalışır, ileride Google Places API'ye geçişi soyutlar.
abstract class HospitalRepository {
  Future<List<Hospital>> searchHospitals({
    String? province,
    String? district,
    String query = '',
  });
}

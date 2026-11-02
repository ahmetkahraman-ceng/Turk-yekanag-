import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Türkiye il ve ilçe verisi modeli (`assets/data/turkey_provinces_districts.json`).
class TurkeyProvince {
  const TurkeyProvince({
    required this.plate,
    required this.name,
    required this.districts,
  });

  factory TurkeyProvince.fromJson(Map<String, dynamic> json) {
    final rawDistricts = json['districts'] as List<dynamic>? ?? const [];
    return TurkeyProvince(
      plate: (json['plate'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String? ?? '').trim(),
      districts: rawDistricts
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false),
    );
  }

  final int plate;
  final String name;
  final List<String> districts;
}

/// Yerel JSON dosyasından 81 il ve ilçelerini yükleyen sağlayıcı.
final turkeyProvincesProvider = FutureProvider<List<TurkeyProvince>>((
  ref,
) async {
  final jsonString = await rootBundle.loadString(
    'assets/data/turkey_provinces_districts.json',
  );
  final list = jsonDecode(jsonString) as List<dynamic>;
  return list
      .map((item) => TurkeyProvince.fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
});

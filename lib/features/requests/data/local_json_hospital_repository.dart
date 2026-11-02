import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/features/requests/domain/hospital.dart';

/// Yerel JSON (`assets/data/turkey_hospitals.json`) tabanlı hastane veri kaynağı.
/// `HospitalRepository` arayüzünü uygular; ileride Google Places API'ye geçişte
/// yalnızca provider tanımı değiştirilerek aynı arayüz korunur.
class LocalJsonHospitalRepository implements HospitalRepository {
  LocalJsonHospitalRepository({List<Hospital>? seedHospitals})
      : _cached = seedHospitals;

  List<Hospital>? _cached;

  Future<List<Hospital>> _loadAll() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/data/turkey_hospitals.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cached = decoded
        .map((e) => Hospital.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return _cached!;
  }

  String _normalizeTr(String input) {
    return input
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .toLowerCase();
  }

  @override
  Future<List<Hospital>> searchHospitals({
    String? province,
    String? district,
    String query = '',
  }) async {
    final all = await _loadAll();
    final q = _normalizeTr(query);

    return all.where((h) {
      if (province != null &&
          province.isNotEmpty &&
          h.province != province) {
        return false;
      }
      if (district != null &&
          district.isNotEmpty &&
          h.district != district) {
        return false;
      }
      if (q.isEmpty) return true;
      return _normalizeTr(h.name).contains(q) ||
          _normalizeTr(h.province).contains(q) ||
          _normalizeTr(h.district).contains(q);
    }).toList(growable: false);
  }
}

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return LocalJsonHospitalRepository();
});

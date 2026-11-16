import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/core/mock/donation_center.dart';
import 'package:turkiye_kan_agi/core/mock/mock_data.dart';

/// Bağış merkezi repository soyut arayüzü.
abstract class CenterRepository {
  Future<Result<List<DonationCenter>>> fetchCenters({String? province});
  Future<Result<DonationCenter?>> getCenterById(String id);
}

/// Fake bağış merkezi repository implementasyonu.
class FakeCenterRepository implements CenterRepository {
  FakeCenterRepository({List<DonationCenter>? seedCenters})
      : _centers = List<DonationCenter>.of(seedCenters ?? MockData.centers);

  final List<DonationCenter> _centers;

  @override
  Future<Result<List<DonationCenter>>> fetchCenters({String? province}) async {
    if (province == null || province.isEmpty) {
      return Result.success(List<DonationCenter>.unmodifiable(_centers));
    }
    return Result.success(
      _centers.where((c) => c.province == province).toList(),
    );
  }

  @override
  Future<Result<DonationCenter?>> getCenterById(String id) async {
    return Result.success(_centers.where((c) => c.id == id).firstOrNull);
  }
}

final centerRepositoryProvider = Provider<CenterRepository>((ref) {
  return FakeCenterRepository();
});

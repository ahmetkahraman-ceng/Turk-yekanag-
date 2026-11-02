import 'package:flutter_test/flutter_test.dart';
import 'package:turkiye_kan_agi/core/utils/version_comparator.dart';

void main() {
  group('VersionComparator', () {
    test('mevcut sürüm min_version değerinden küçükse true döner', () {
      expect(
        VersionComparator.isUpdateRequired(
          currentVersion: '1.0.0',
          minVersion: '1.0.1',
        ),
        isTrue,
      );
      expect(
        VersionComparator.isUpdateRequired(
          currentVersion: '1.2.9',
          minVersion: '2.0.0',
        ),
        isTrue,
      );
    });

    test('mevcut sürüm min_version değerine eşit veya büyükse false döner', () {
      expect(
        VersionComparator.isUpdateRequired(
          currentVersion: '1.0.0',
          minVersion: '1.0.0',
        ),
        isFalse,
      );
      expect(
        VersionComparator.isUpdateRequired(
          currentVersion: '1.3.0+5',
          minVersion: '1.2.9',
        ),
        isFalse,
      );
    });
  });
}

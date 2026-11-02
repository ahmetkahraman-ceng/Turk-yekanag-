/// Semantik sürüm (x.y.z) karşılaştırma yardımcısı.
/// Force Update (zorunlu güncelleme) kontrolünde kullanılır.
abstract final class VersionComparator {
  /// [currentVersion], [minVersion] değerinden küçükse `true` döner.
  static bool isUpdateRequired({
    required String currentVersion,
    required String minVersion,
  }) {
    final currentParts = _parseVersion(currentVersion);
    final minParts = _parseVersion(minVersion);

    for (var i = 0; i < 3; i++) {
      if (currentParts[i] < minParts[i]) {
        return true;
      }
      if (currentParts[i] > minParts[i]) {
        return false;
      }
    }
    return false;
  }

  static List<int> _parseVersion(String version) {
    final cleaned = version.split('+').first.split('-').first.trim();
    final segments = cleaned.split('.');
    final result = <int>[0, 0, 0];
    for (var i = 0; i < 3 && i < segments.length; i++) {
      result[i] = int.tryParse(segments[i]) ?? 0;
    }
    return result;
  }
}

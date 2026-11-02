/// Merkezi boşluk, kenar yuvarlaklığı ve erişilebilirlik boyut sabitleri.
abstract final class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  /// Erişilebilirlik kuralı: minimum dokunma alanı (48dp x 48dp).
  static const double minTouchTarget = 48.0;

  /// Kenar yuvarlaklığı sabitleri.
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
}

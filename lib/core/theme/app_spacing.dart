/// Merkezi boşluk ve ölçü token sınıfı.
/// Boşluk ölçeği: 4 / 8 / 12 / 16 / 24 / 32.
/// Dokunma alanı minimum 48dp, ana buton yüksekliği 52dp, içerik max genişlik 600dp.
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

  /// Ana eylem butonu yüksekliği (52dp).
  static const double primaryButtonHeight = 52.0;

  /// Büyük ekranlarda içerik maksimum genişliği (600dp).
  static const double maxContentWidth = 600.0;

  /// Admin paneli maksimum genişliği.
  static const double adminMaxContentWidth = 1440.0;

  // Geriye dönük uyumluluk sabitleri (AppRadius ile eşdeğer)
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
}

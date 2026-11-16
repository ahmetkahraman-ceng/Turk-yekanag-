import 'package:flutter/widgets.dart';

/// Merkezi hareket (animasyon süreleri ve eğrileri) token sınıfı.
/// Süreler: 150ms / 250ms / 400ms.
/// Eğriler: easeOutCubic ve easeInOutCubic.
/// MediaQuery.disableAnimations açıksa animasyonlar kapanır/kısalır.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration splashTotal = Duration(milliseconds: 2600);
  static const Duration splashReduced = Duration(milliseconds: 800);

  static const Curve outCurve = Curves.easeOutCubic;
  static const Curve inOutCurve = Curves.easeInOutCubic;

  /// Buton basma ölçeği geri bildirimi.
  static const double pressedScale = 0.97;

  /// Kullanıcının erişilebilirlik tercihine göre animasyon kapalı mı?
  static bool isAnimationsDisabled(BuildContext context) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  /// disableAnimations açıksa Duration.zero, değilse verilen süreyi döndürür.
  static Duration resolveDuration(BuildContext context, Duration base) {
    if (isAnimationsDisabled(context)) {
      return Duration.zero;
    }
    return base;
  }
}

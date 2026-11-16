import 'package:flutter/material.dart';

/// Merkezi renk token sınıfı.
/// Tasarım değerleri:
/// Aydınlık: primary #D32F2F, primaryDark #9A0007, primaryLight #FF6659,
/// background #FFF8F6, surface #FFFFFF, textPrimary #2B1B1B,
/// textSecondary #6B5B5B, success #2E7D32, warning #EF6C00,
/// info #1565C0, error #B00020.
/// Karanlık: background #1A0E0E, surface #261616, primary #EF5350,
/// textPrimary #F5E9E7.
abstract final class AppColors {
  // Marka ve Birincil Renkler (Aydınlık)
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFF9A0007);
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFFDAD6);
  static const Color onPrimaryContainer = Color(0xFF410002);

  // Zemin ve Yüzey (Aydınlık)
  static const Color background = Color(0xFFFFF8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5E4E1);
  static const Color border = Color(0xFFE6D2CE);

  // Metin (Aydınlık - 4.5:1+ yüksek kontrast)
  static const Color textPrimary = Color(0xFF2B1B1B);
  static const Color textSecondary = Color(0xFF6B5B5B);

  // Karanlık Tema Token'ları
  static const Color darkPrimary = Color(0xFFEF5350);
  static const Color onDarkPrimary = Color(0xFF2B1B1B);
  static const Color darkPrimaryContainer = Color(0xFF7F1D1D);
  static const Color onDarkPrimaryContainer = Color(0xFFFFDAD6);
  static const Color darkBackground = Color(0xFF1A0E0E);
  static const Color darkSurface = Color(0xFF261616);
  static const Color darkSurfaceVariant = Color(0xFF382222);
  static const Color darkBorder = Color(0xFF4D3333);
  static const Color darkTextPrimary = Color(0xFFF5E9E7);
  static const Color darkTextSecondary = Color(0xFFD0BEBB);

  // Anlamsal Renkler (Her renk yazı veya ikonla birlikte kullanılır)
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color darkSuccessLight = Color(0xFF1B3B1E);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFEF6C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color darkWarningLight = Color(0xFF3E240B);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color darkInfoLight = Color(0xFF102A45);
  static const Color onInfo = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFB00020);
  static const Color errorDark = Color(0xFFFF8A80);
  static const Color errorLight = Color(0xFFFDECEA);
  static const Color darkErrorLight = Color(0xFF421218);
  static const Color onError = Color(0xFFFFFFFF);

  // Nötr Etiket / Bu Hafta / Pasif
  static const Color neutralTag = Color(0xFF6B5B5B);
  static const Color neutralTagBg = Color(0xFFF0E6E4);
  static const Color darkNeutralTagBg = Color(0xFF382626);

  // Skeleton Renkleri
  static const Color skeletonBaseLight = Color(0xFFEDE0DD);
  static const Color skeletonHighlightLight = Color(0xFFFAF2F0);
  static const Color skeletonBaseDark = Color(0xFF352121);
  static const Color skeletonHighlightDark = Color(0xFF4A3030);

  // Geriye dönük uyumluluk takma adları
  static const Color onPrimaryLight = onPrimary;
  static const Color primaryContainerLight = primaryContainer;
  static const Color onPrimaryContainerLight = onPrimaryContainer;
  static const Color onPrimaryDark = onDarkPrimary;
  static const Color primaryContainerDark = darkPrimaryContainer;
  static const Color onPrimaryContainerDark = onDarkPrimaryContainer;
  static const Color secondaryLight = textSecondary;
  static const Color onSecondaryLight = surface;
  static const Color secondaryDark = darkTextSecondary;
  static const Color onSecondaryDark = darkBackground;
  static const Color backgroundLight = background;
  static const Color surfaceLight = surface;
  static const Color surfaceVariantLight = surfaceVariant;
  static const Color onSurfaceLight = textPrimary;
  static const Color onSurfaceVariantLight = textSecondary;
  static const Color backgroundDark = darkBackground;
  static const Color surfaceDark = darkSurface;
  static const Color surfaceVariantDark = darkSurfaceVariant;
  static const Color onSurfaceDark = darkTextPrimary;
  static const Color onSurfaceVariantDark = darkTextSecondary;
}

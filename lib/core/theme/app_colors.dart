import 'package:flutter/material.dart';

/// Merkezi renk sabitleri (Material 3 uyumlu, yüksek kontrastlı kırmızı tonları).
abstract final class AppColors {
  // Primary Red Palette (High Contrast)
  static const Color primaryLight = Color(0xFFB71C1C);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFFFDAD6);
  static const Color onPrimaryContainerLight = Color(0xFF410002);

  static const Color primaryDark = Color(0xFFFFB4AB);
  static const Color onPrimaryDark = Color(0xFF690005);
  static const Color primaryContainerDark = Color(0xFF93000A);
  static const Color onPrimaryContainerDark = Color(0xFFFFDAD6);

  // Secondary & Tertiary
  static const Color secondaryLight = Color(0xFF775652);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryDark = Color(0xFFE7BDB7);
  static const Color onSecondaryDark = Color(0xFF442926);

  // Surfaces & Backgrounds
  static const Color backgroundLight = Color(0xFFFFFBFF);
  static const Color surfaceLight = Color(0xFFFFFBFF);
  static const Color surfaceVariantLight = Color(0xFFF5DDDA);
  static const Color onSurfaceLight = Color(0xFF201A19);
  static const Color onSurfaceVariantLight = Color(0xFF534341);

  static const Color backgroundDark = Color(0xFF181211);
  static const Color surfaceDark = Color(0xFF201A19);
  static const Color surfaceVariantDark = Color(0xFF534341);
  static const Color onSurfaceDark = Color(0xFFEDE0DE);
  static const Color onSurfaceVariantDark = Color(0xFFD8C2BF);

  // Semantic Colors
  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color warning = Color(0xFFE65100);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Skeleton Colors
  static const Color skeletonBaseLight = Color(0xFFE6D6D4);
  static const Color skeletonHighlightLight = Color(0xFFF7ECEA);
  static const Color skeletonBaseDark = Color(0xFF3A2E2C);
  static const Color skeletonHighlightDark = Color(0xFF4E3F3D);
}

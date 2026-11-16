import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';

/// Merkezi gölge token sınıfı.
abstract final class AppShadows {
  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> bottomBarLight = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> bottomBarDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> cardFor(Brightness brightness) =>
      brightness == Brightness.dark ? cardDark : cardLight;

  static List<BoxShadow> bottomBarFor(Brightness brightness) =>
      brightness == Brightness.dark ? bottomBarDark : bottomBarLight;
}

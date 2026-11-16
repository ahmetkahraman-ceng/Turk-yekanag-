import 'package:flutter/material.dart';

/// Merkezi köşe yuvarlaklığı token sınıfı.
/// Kart: 20, Buton: 16, Çip: 999, Bottom Sheet üst köşe: 28.
abstract final class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double button = 16.0;
  static const double input = 16.0;
  static const double card = 20.0;
  static const double bottomSheetTop = 28.0;
  static const double chip = 999.0;

  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius buttonBorder = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius inputBorder = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius chipBorder = BorderRadius.all(
    Radius.circular(chip),
  );
  static const BorderRadius bottomSheetBorder = BorderRadius.vertical(
    top: Radius.circular(bottomSheetTop),
  );
}

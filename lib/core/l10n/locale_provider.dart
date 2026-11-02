import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama dilini (varsayılan Türkçe 'tr', alternatif İngilizce 'en') yöneten sağlayıcı.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('tr');

  void setLocale(Locale locale) {
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

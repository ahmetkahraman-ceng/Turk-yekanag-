import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hata yönetimi ve Crashlytics loglama arayüzü.
abstract class ErrorLogger {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  Future<void> log(String message);
}

/// Firebase Crashlytics tabanlı hata kaydedici.
/// Firebase başlatılmadığında (test/yerel mod) güvenli şekilde konsola yazar.
class CrashlyticsLogger implements ErrorLogger {
  CrashlyticsLogger({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics;

  final FirebaseCrashlytics? _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      final instance = _crashlytics;
      if (instance != null) {
        await instance.recordError(
          error,
          stackTrace,
          reason: reason,
          fatal: fatal,
        );
      } else {
        debugPrint('ErrorLogger [$reason]: $error');
      }
    } catch (_) {
      debugPrint('ErrorLogger fallback [$reason]: $error');
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      final instance = _crashlytics;
      if (instance != null) {
        await instance.log(message);
      } else {
        debugPrint('Log: $message');
      }
    } catch (_) {
      debugPrint('Log fallback: $message');
    }
  }
}

final errorLoggerProvider = Provider<ErrorLogger>((ref) {
  return CrashlyticsLogger();
});

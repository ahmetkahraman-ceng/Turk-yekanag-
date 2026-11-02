import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:turkiye_kan_agi/core/config/app_environment.dart';
import 'package:turkiye_kan_agi/core/config/firebase_options_dev.dart';
import 'package:turkiye_kan_agi/core/config/firebase_options_prod.dart';

/// Firebase servislerini seçilen ortama (dev/prod) ve Emulator Suite ayarlarına göre başlatır.
abstract final class FirebaseInitializer {
  static Future<bool> initialize(AppEnvironment env) async {
    try {
      final options = env.isProd
          ? FirebaseOptionsProd.currentPlatform
          : FirebaseOptionsDev.currentPlatform;

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }

      if (env.useFirebaseEmulator) {
        await _connectToEmulators(env.emulatorHost);
      } else {
        await _configureProductionServices(env);
      }
      return true;
    } catch (error, stackTrace) {
      debugPrint('Firebase başlatma uyarısı (yerel/test modu): $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  static Future<void> _connectToEmulators(String host) async {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  static Future<void> _configureProductionServices(AppEnvironment env) async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await FirebaseAppCheck.instance.activate(
      androidProvider: env.isProd
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug,
      appleProvider:
          env.isProd ? AppleProvider.deviceCheck : AppleProvider.debug,
    );
  }
}

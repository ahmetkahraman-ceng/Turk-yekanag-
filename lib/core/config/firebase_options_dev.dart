import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// DEV ortamı için Firebase yapılandırması.
/// Gizli anahtarlar koda gömülmez; --dart-define-from-file=.env.dev ile enjekte edilir.
abstract final class FirebaseOptionsDev {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: 'demo-dev-api-key',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_APP_ID_ANDROID',
      defaultValue: '1:000000000000:android:dev000000000000',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '000000000000',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'turkiye-kan-agi-dev',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'turkiye-kan-agi-dev.appspot.com',
    ),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: 'demo-dev-api-key',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_APP_ID_IOS',
      defaultValue: '1:000000000000:ios:dev000000000000',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '000000000000',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'turkiye-kan-agi-dev',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'turkiye-kan-agi-dev.appspot.com',
    ),
    iosBundleId: String.fromEnvironment(
      'IOS_BUNDLE_ID',
      defaultValue: 'tr.org.kanagi.turkiyeKanAgi.dev',
    ),
  );
}

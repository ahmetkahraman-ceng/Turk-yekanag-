import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// PROD ortamı için Firebase yapılandırması.
/// Gizli anahtarlar koda gömülmez; --dart-define-from-file=.env.prod ile enjekte edilir.
abstract final class FirebaseOptionsProd {
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
      defaultValue: 'prod-api-key-placeholder',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_APP_ID_ANDROID',
      defaultValue: '1:111111111111:android:prod111111111111',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '111111111111',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'turkiye-kan-agi-prod',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'turkiye-kan-agi-prod.appspot.com',
    ),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: 'prod-api-key-placeholder',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_APP_ID_IOS',
      defaultValue: '1:111111111111:ios:prod111111111111',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '111111111111',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'turkiye-kan-agi-prod',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'turkiye-kan-agi-prod.appspot.com',
    ),
    iosBundleId: String.fromEnvironment(
      'IOS_BUNDLE_ID',
      defaultValue: 'tr.org.kanagi.turkiyeKanAgi',
    ),
  );
}

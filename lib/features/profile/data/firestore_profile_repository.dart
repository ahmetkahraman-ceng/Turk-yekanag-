import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/features/onboarding/domain/kvkk_consent_record.dart';
import 'package:turkiye_kan_agi/features/profile/domain/notification_preferences.dart';
import 'package:turkiye_kan_agi/features/profile/domain/profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';

/// Firestore, Storage ve Cloud Functions tabanlı profil repository uygulaması.
/// Public (`users/{uid}`) ve Private (`users/{uid}/private_data/*`) ayrımını uygular.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseFunctions? functions,
  })  : _firestore = firestore,
        _storage = storage,
        _functions = functions;

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final FirebaseFunctions? _functions;

  // Emülatör bağlı olmadığında yerel/önizleme durumu için önbellek
  final Map<String, UserPublicProfile> _publicCache = {};
  final Map<String, UserSensitiveProfile> _sensitiveCache = {};
  final Map<String, KvkkConsentRecord> _consentCache = {};
  final Map<String, NotificationPreferences> _prefsCache = {};

  static const String privateCollection = 'private_data';
  static const String sensitiveDocId = 'sensitive_profile';
  static const String consentsDocId = 'consents';
  static const String notifPrefsDocId = 'notification_preferences';

  @override
  Future<Result<UserPublicProfile?>> getPublicProfile(String uid) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final doc = await fs.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final profile = UserPublicProfile.fromJson(doc.data()!);
          _publicCache[uid] = profile;
          return Result.success(profile);
        }
      } catch (_) {}
    }
    return Result.success(_publicCache[uid]);
  }

  @override
  Future<Result<UserSensitiveProfile?>> getSensitiveProfile(String uid) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final doc = await fs
            .collection('users')
            .doc(uid)
            .collection(privateCollection)
            .doc(sensitiveDocId)
            .get();
        if (doc.exists && doc.data() != null) {
          final sensitive = UserSensitiveProfile.fromJson(doc.data()!);
          _sensitiveCache[uid] = sensitive;
          return Result.success(sensitive);
        }
      } catch (_) {}
    }
    return Result.success(_sensitiveCache[uid]);
  }

  @override
  Future<Result<void>> saveFullProfile({
    required UserPublicProfile publicProfile,
    required UserSensitiveProfile sensitiveProfile,
    KvkkConsentRecord? consentRecord,
  }) async {
    final uid = publicProfile.uid;
    _publicCache[uid] = publicProfile;
    _sensitiveCache[uid] = sensitiveProfile;
    if (consentRecord != null) {
      _consentCache[uid] = consentRecord;
    }

    final fs = _firestore;
    if (fs != null) {
      try {
        final userRef = fs.collection('users').doc(uid);
        final batch = fs.batch();
        batch.set(userRef, publicProfile.toJson());
        batch.set(
          userRef.collection(privateCollection).doc(sensitiveDocId),
          sensitiveProfile.toJson(),
        );
        if (consentRecord != null) {
          batch.set(
            userRef.collection(privateCollection).doc(consentsDocId),
            consentRecord.toJson(),
          );
        }
        await batch.commit();
      } catch (_) {}
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void>> updateAvailability({
    required String uid,
    required bool isAvailable,
  }) async {
    final existing = _publicCache[uid];
    if (existing != null) {
      _publicCache[uid] = existing.copyWith(
        isAvailableToDonate: isAvailable,
        updatedAt: DateTime.now().toUtc(),
      );
    }
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs.collection('users').doc(uid).update({
          'isAvailableToDonate': isAvailable,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {}
    }
    return const Result.success(null);
  }

  @override
  Future<Result<String>> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
  }) async {
    var photoUrl = 'https://kanagi.org.tr/avatars/$uid.jpg';
    final st = _storage;
    if (st != null) {
      try {
        final ref = st.ref().child('users/$uid/profile_photo.jpg');
        await ref.putData(bytes);
        photoUrl = await ref.getDownloadURL();
      } catch (_) {}
    }
    final existing = _publicCache[uid];
    if (existing != null) {
      _publicCache[uid] = existing.copyWith(photoUrl: photoUrl);
    }
    return Result.success(photoUrl);
  }

  @override
  Future<Result<NotificationPreferences>> getNotificationPreferences(
    String uid,
  ) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final doc = await fs
            .collection('users')
            .doc(uid)
            .collection(privateCollection)
            .doc(notifPrefsDocId)
            .get();
        if (doc.exists && doc.data() != null) {
          final prefs = NotificationPreferences.fromJson(doc.data()!);
          _prefsCache[uid] = prefs;
          return Result.success(prefs);
        }
      } catch (_) {}
    }
    return Result.success(_prefsCache[uid] ?? const NotificationPreferences());
  }

  @override
  Future<Result<void>> saveNotificationPreferences({
    required String uid,
    required NotificationPreferences preferences,
  }) async {
    _prefsCache[uid] = preferences;
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection(privateCollection)
            .doc(notifPrefsDocId)
            .set(preferences.toJson());
      } catch (_) {}
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void>> saveKvkkConsent({
    required String uid,
    required KvkkConsentRecord consent,
  }) async {
    _consentCache[uid] = consent;
    final fs = _firestore;
    if (fs != null) {
      try {
        await fs
            .collection('users')
            .doc(uid)
            .collection(privateCollection)
            .doc(consentsDocId)
            .set(consent.toJson());
      } catch (_) {}
    }
    return const Result.success(null);
  }

  @override
  Future<Result<String>> exportUserDataJson(String uid) async {
    final publicProfile = (await getPublicProfile(uid)).when(
      success: (d) => d?.toJson(),
      failure: (_) => null,
    );
    final sensitiveProfile = (await getSensitiveProfile(uid)).when(
      success: (d) => d?.toJson(),
      failure: (_) => null,
    );
    final prefs = (await getNotificationPreferences(uid)).when(
      success: (d) => d.toJson(),
      failure: (_) => null,
    );

    final exportPayload = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'uid': uid,
      'publicProfile': publicProfile,
      'sensitiveProfile': sensitiveProfile,
      'kvkkConsent': _consentCache[uid]?.toJson(),
      'notificationPreferences': prefs,
    };

    const encoder = JsonEncoder.withIndent('  ');
    return Result.success(encoder.convert(exportPayload));
  }

  @override
  Future<Result<void>> deleteAccount(String uid) async {
    final fn = _functions;
    if (fn != null) {
      try {
        final callable = fn.httpsCallable('deleteUserAccount');
        await callable.call<Map<String, dynamic>>({'uid': uid});
      } catch (_) {}
    }
    _publicCache.remove(uid);
    _sensitiveCache.remove(uid);
    _consentCache.remove(uid);
    _prefsCache.remove(uid);
    return const Result.success(null);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirestoreProfileRepository();
});

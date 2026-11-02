import 'dart:typed_data';
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/features/onboarding/domain/kvkk_consent_record.dart';
import 'package:turkiye_kan_agi/features/profile/domain/notification_preferences.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';

/// Profil, KVKK rıza kaydı, bildirim tercihleri, veri indirme ve hesap silme repository arayüzü.
abstract class ProfileRepository {
  Future<Result<UserPublicProfile?>> getPublicProfile(String uid);
  Future<Result<UserSensitiveProfile?>> getSensitiveProfile(String uid);

  Future<Result<void>> saveFullProfile({
    required UserPublicProfile publicProfile,
    required UserSensitiveProfile sensitiveProfile,
    KvkkConsentRecord? consentRecord,
  });

  Future<Result<void>> updateAvailability({
    required String uid,
    required bool isAvailable,
  });

  Future<Result<String>> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
  });

  Future<Result<NotificationPreferences>> getNotificationPreferences(
    String uid,
  );

  Future<Result<void>> saveNotificationPreferences({
    required String uid,
    required NotificationPreferences preferences,
  });

  Future<Result<void>> saveKvkkConsent({
    required String uid,
    required KvkkConsentRecord consent,
  });

  Future<Result<KvkkConsentRecord?>> getKvkkConsent(String uid);

  /// Kullanıcının tüm verilerini (public, sensitive, consents, preferences) biçimlendirilmiş JSON metni olarak dışa aktarır.
  Future<Result<String>> exportUserDataJson(String uid);

  /// Cloud Function (`deleteUserAccount`) aracılığıyla kullanıcının tüm verilerini ve hesabını kalıcı olarak siler.
  Future<Result<void>> deleteAccount(String uid);
}

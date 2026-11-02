import 'package:turkiye_kan_agi/core/error/result.dart';

/// Kimlik doğrulama (Telefon OTP, Google, Apple) repository arayüzü.
/// UI katmanı doğrudan Firebase Auth'a erişmez.
abstract class AuthRepository {
  String? get currentUserId;
  Stream<String?> get authStateChanges;

  /// Türkiye cep telefonu numarasına (`+905XXXXXXXXX`) SMS OTP gönderir.
  /// Başarılı olduğunda `verificationId` döner.
  Future<Result<String>> sendPhoneOtp({
    required String phoneNumber,
  });

  /// `verificationId` ve 6 haneli `smsCode` ile oturum açar.
  /// Başarılı olduğunda `userId` (`uid`) döner.
  Future<Result<String>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Google hesabı ile giriş yapar.
  Future<Result<String>> signInWithGoogle();

  /// Apple hesabı ile giriş yapar.
  Future<Result<String>> signInWithApple();

  /// Mevcut oturumu kapatır.
  Future<Result<void>> signOut();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/features/onboarding/domain/kvkk_consent_record.dart';

/// Onboarding slaytlarının tamamlanıp tamamlanmadığını tutan sağlayıcı.
class OnboardingCompletedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markCompleted() {
    state = true;
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
  OnboardingCompletedNotifier.new,
);

/// Kullanıcının onayladığı KVKK açık rıza kaydını tutan sağlayıcı.
/// Giriş tamamlandığında Firestore `users/{uid}/private_data/consents` altına yazılır.
class KvkkConsentNotifier extends Notifier<KvkkConsentRecord?> {
  @override
  KvkkConsentRecord? build() => null;

  void approveAll({DateTime? timestamp}) {
    state = KvkkConsentRecord(
      healthDataConsent: true,
      locationConsent: true,
      notificationConsent: true,
      consentedAt: timestamp ?? DateTime.now().toUtc(),
      policyVersion: KvkkConsentRecord.currentPolicyVersion,
    );
  }

  void setRecord(KvkkConsentRecord? record) {
    state = record;
  }
}

final kvkkConsentProvider =
    NotifierProvider<KvkkConsentNotifier, KvkkConsentRecord?>(
  KvkkConsentNotifier.new,
);

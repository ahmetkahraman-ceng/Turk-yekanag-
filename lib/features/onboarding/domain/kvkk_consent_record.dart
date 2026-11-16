/// KVKK açık rıza kaydı modeli.
/// Firestore `users/{uid}/private_data/consents` dokümanında saklanır.
class KvkkConsentRecord {
  const KvkkConsentRecord({
    required this.healthDataConsent,
    required this.locationConsent,
    required this.notificationConsent,
    required this.consentedAt,
    required this.policyVersion,
  });

  factory KvkkConsentRecord.fromJson(Map<String, dynamic> json) {
    return KvkkConsentRecord(
      healthDataConsent: json['healthDataConsent'] as bool? ?? false,
      locationConsent: json['locationConsent'] as bool? ?? false,
      notificationConsent: json['notificationConsent'] as bool? ?? false,
      consentedAt: DateTime.tryParse(json['consentedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      policyVersion: json['policyVersion'] as String? ?? currentPolicyVersion,
    );
  }

  static const String currentPolicyVersion = '1.0.0';

  final bool healthDataConsent;
  final bool locationConsent;
  final bool notificationConsent;
  final DateTime consentedAt;
  final String policyVersion;

  bool get allMandatoryConsentsGranted =>
      healthDataConsent && locationConsent;

  bool get isFullyApproved =>
      healthDataConsent && locationConsent && notificationConsent;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'healthDataConsent': healthDataConsent,
      'locationConsent': locationConsent,
      'notificationConsent': notificationConsent,
      'consentedAt': consentedAt.toUtc().toIso8601String(),
      'policyVersion': policyVersion,
    };
  }
}

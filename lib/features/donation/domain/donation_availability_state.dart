/// `users/{uid}/private_data/donation_status` dokümanı.
/// "Bağışa uygunum" anahtarının otomatik kapatılıp açılması ve hatırlatıcı tercihi.
/// Sonraki uygun tarih bağış geçmişinden türediği için özel veridir (yalnızca sahibi).
class DonationAvailabilityState {
  const DonationAvailabilityState({
    this.autoPaused = false,
    this.reminderEnabled = true,
    this.nextEligibleAt,
  });

  factory DonationAvailabilityState.fromJson(Map<String, dynamic> json) {
    return DonationAvailabilityState(
      autoPaused: json['autoPaused'] as bool? ?? false,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      nextEligibleAt:
          DateTime.tryParse(json['nextEligibleAt'] as String? ?? '')?.toUtc(),
    );
  }

  /// Anahtar sistem tarafından (bekleme süresi nedeniyle) kapatıldıysa `true`.
  final bool autoPaused;
  final bool reminderEnabled;
  final DateTime? nextEligibleAt;

  DonationAvailabilityState copyWith({
    bool? autoPaused,
    bool? reminderEnabled,
    DateTime? nextEligibleAt,
    bool clearNextEligibleAt = false,
  }) {
    return DonationAvailabilityState(
      autoPaused: autoPaused ?? this.autoPaused,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      nextEligibleAt:
          clearNextEligibleAt ? null : (nextEligibleAt ?? this.nextEligibleAt),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'autoPaused': autoPaused,
        'reminderEnabled': reminderEnabled,
        'nextEligibleAt': nextEligibleAt?.toUtc().toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
}

/// Otomatik "Bağışa uygunum" güncelleme kararı.
class AvailabilityDecision {
  const AvailabilityDecision({
    required this.newIsAvailable,
    required this.newAutoPaused,
  });

  final bool newIsAvailable;
  final bool newAutoPaused;
}

/// Saf karar fonksiyonu:
/// - Bekleme süresi dolmamış ve anahtar açıksa → kapat, `autoPaused = true`
/// - Süre dolmuş ve anahtarı sistem kapatmışsa → aç, `autoPaused = false`
/// - Kullanıcı anahtarı kendisi kapattıysa (`autoPaused == false`) → dokunma
abstract final class AvailabilityAutoUpdater {
  static AvailabilityDecision decide({
    required bool isEligibleNow,
    required bool isAvailable,
    required bool autoPaused,
  }) {
    if (!isEligibleNow) {
      if (isAvailable) {
        return const AvailabilityDecision(
          newIsAvailable: false,
          newAutoPaused: true,
        );
      }
      return AvailabilityDecision(
        newIsAvailable: false,
        newAutoPaused: autoPaused,
      );
    }
    if (autoPaused) {
      return const AvailabilityDecision(
        newIsAvailable: true,
        newAutoPaused: false,
      );
    }
    return AvailabilityDecision(
      newIsAvailable: isAvailable,
      newAutoPaused: false,
    );
  }
}

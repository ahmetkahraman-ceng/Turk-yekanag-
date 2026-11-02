/// Bildirim aciliyet filtresi seçenekleri.
enum NotificationUrgencyFilter {
  all('all'),
  urgentOnly('urgent_only'),
  criticalOnly('critical_only');

  const NotificationUrgencyFilter(this.code);
  final String code;

  static NotificationUrgencyFilter fromCode(String? code) {
    for (final value in values) {
      if (value.code == code) {
        return value;
      }
    }
    return NotificationUrgencyFilter.all;
  }
}

/// Kullanıcının bildirim tercihleri (`users/{uid}/private_data/notification_preferences`).
class NotificationPreferences {
  const NotificationPreferences({
    this.minUrgency = NotificationUrgencyFilter.all,
    this.radiusKm = 25,
    this.quietHoursEnabled = false,
    this.quietStartHour = 23,
    this.quietEndHour = 7,
    this.allowCriticalInQuietHours = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final radius = (json['radiusKm'] as num?)?.toInt() ?? 25;
    return NotificationPreferences(
      minUrgency: NotificationUrgencyFilter.fromCode(
        json['minUrgency'] as String?,
      ),
      radiusKm: supportedRadiiKm.contains(radius) ? radius : 25,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietStartHour: (json['quietStartHour'] as num?)?.toInt() ?? 23,
      quietEndHour: (json['quietEndHour'] as num?)?.toInt() ?? 7,
      allowCriticalInQuietHours:
          json['allowCriticalInQuietHours'] as bool? ?? true,
    );
  }

  /// Desteklenen yarıçap seçenekleri (km).
  static const List<int> supportedRadiiKm = <int>[5, 10, 25, 50];

  final NotificationUrgencyFilter minUrgency;
  final int radiusKm;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;
  final bool allowCriticalInQuietHours;

  NotificationPreferences copyWith({
    NotificationUrgencyFilter? minUrgency,
    int? radiusKm,
    bool? quietHoursEnabled,
    bool? allowCriticalInQuietHours,
  }) {
    return NotificationPreferences(
      minUrgency: minUrgency ?? this.minUrgency,
      radiusKm: radiusKm ?? this.radiusKm,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour,
      quietEndHour: quietEndHour,
      allowCriticalInQuietHours:
          allowCriticalInQuietHours ?? this.allowCriticalInQuietHours,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'minUrgency': minUrgency.code,
      'radiusKm': radiusKm,
      'quietHoursEnabled': quietHoursEnabled,
      'quietStartHour': quietStartHour,
      'quietEndHour': quietEndHour,
      'allowCriticalInQuietHours': allowCriticalInQuietHours,
    };
  }
}

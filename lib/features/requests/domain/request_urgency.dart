import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';

/// Kan talebi aciliyet seviyeleri.
enum RequestUrgency {
  critical('critical', 3),
  today('today', 2),
  thisWeek('this_week', 1);

  const RequestUrgency(this.code, this.priorityWeight);
  final String code;
  final int priorityWeight;

  static RequestUrgency fromCode(String? raw) {
    for (final item in RequestUrgency.values) {
      if (item.code == raw) return item;
    }
    return RequestUrgency.today;
  }

  /// Aciliyete göre otomatik süre dolum saatini Remote Config'ten hesaplar.
  DateTime calculateExpiryFrom(
    DateTime createdAtUtc,
    RemoteConfigService remoteConfig,
  ) {
    final hours = switch (this) {
      RequestUrgency.critical => remoteConfig.expiryHoursCritical,
      RequestUrgency.today => remoteConfig.expiryHoursToday,
      RequestUrgency.thisWeek => remoteConfig.expiryHoursThisWeek,
    };
    return createdAtUtc.add(Duration(hours: hours));
  }
}

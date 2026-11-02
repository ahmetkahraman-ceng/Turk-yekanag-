import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:turkiye_kan_agi/core/error/result.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_reminder_service.dart';

/// `flutter_local_notifications` tabanlı "tekrar bağış yapabilirsin" hatırlatıcı servisi.
class LocalNotificationReminderService implements DonationReminderService {
  LocalNotificationReminderService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin;

  final FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;
  DateTime? _lastScheduledUtc;

  static const int reminderNotificationId = 4101;
  static const String channelId = 'donation_eligibility_reminder';
  static const String channelName = 'Bağış Uygunluk Hatırlatıcıları';

  DateTime? get lastScheduledUtc => _lastScheduledUtc;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {}

    final plugin = _plugin;
    if (plugin != null) {
      try {
        const androidInit =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosInit = DarwinInitializationSettings();
        await plugin.initialize(
          settings: const InitializationSettings(
            android: androidInit,
            iOS: iosInit,
          ),
        );
      } catch (_) {}
    }
    _initialized = true;
  }

  /// Sonraki uygun bağış tarihi ([eligibleAtUtc]) için yerel saat [reminderHour]'da
  /// bildirim zamanını hesaplar.
  static DateTime computeTriggerUtc({
    required DateTime eligibleAtUtc,
    int reminderHour = 10,
  }) {
    final safeHour = reminderHour.clamp(0, 23);
    final local = eligibleAtUtc.toLocal();
    final candidateLocal = DateTime(
      local.year,
      local.month,
      local.day,
      safeHour,
    );
    final candidateUtc = candidateLocal.toUtc();
    return candidateUtc.isBefore(eligibleAtUtc) ? eligibleAtUtc : candidateUtc;
  }

  @override
  Future<Result<DateTime?>> scheduleNextDonationReminder({
    required DateTime eligibleAtUtc,
    required String title,
    required String body,
    int reminderHour = 10,
  }) async {
    await initialize();
    final nowUtc = DateTime.now().toUtc();
    final triggerUtc = computeTriggerUtc(
      eligibleAtUtc: eligibleAtUtc,
      reminderHour: reminderHour,
    );

    if (!triggerUtc.isAfter(nowUtc)) {
      await cancelNextDonationReminder();
      return const Result.success(null);
    }

    _lastScheduledUtc = triggerUtc;
    final plugin = _plugin;
    if (plugin != null) {
      try {
        final tzDate = tz.TZDateTime.from(triggerUtc, tz.local);
        const details = NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        );
        await plugin.zonedSchedule(
          id: reminderNotificationId,
          title: title,
          body: body,
          scheduledDate: tzDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {}
    }
    return Result.success(triggerUtc);
  }

  @override
  Future<Result<void>> cancelNextDonationReminder() async {
    _lastScheduledUtc = null;
    final plugin = _plugin;
    if (plugin != null) {
      try {
        await plugin.cancel(id: reminderNotificationId);
      } catch (_) {}
    }
    return const Result.success(null);
  }
}

/// `add_2_calendar` tabanlı cihaz takvimine ekleme servisi.
class DeviceCalendarExportService implements CalendarExportService {
  DeviceCalendarExportService({
    Future<bool> Function(Event event)? addEventFn,
  }) : _addEventFn = addEventFn;

  final Future<bool> Function(Event event)? _addEventFn;
  Event? _lastAddedEvent;

  Event? get lastAddedEvent => _lastAddedEvent;

  @override
  Future<Result<bool>> addNextDonationToCalendar({
    required DateTime eligibleAtUtc,
    required String title,
    required String description,
  }) async {
    final startLocal = LocalNotificationReminderService.computeTriggerUtc(
      eligibleAtUtc: eligibleAtUtc,
    ).toLocal();
    final endLocal = startLocal.add(const Duration(hours: 1));
    final event = Event(
      title: title,
      description: description,
      startDate: startLocal,
      endDate: endLocal,
    );
    _lastAddedEvent = event;
    try {
      final fn = _addEventFn ?? Add2Calendar.addEvent2Cal;
      final added = await fn(event);
      return Result.success(added);
    } catch (_) {
      return const Result.success(true);
    }
  }
}

final donationReminderServiceProvider =
    Provider<DonationReminderService>((ref) {
  return LocalNotificationReminderService(
    plugin: FlutterLocalNotificationsPlugin(),
  );
});

final calendarExportServiceProvider = Provider<CalendarExportService>((ref) {
  return DeviceCalendarExportService();
});

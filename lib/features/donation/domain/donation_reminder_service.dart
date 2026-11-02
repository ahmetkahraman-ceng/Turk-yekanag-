import 'package:turkiye_kan_agi/core/error/result.dart';

/// "Tekrar bağış yapabilirsin" yerel bildirim (hatırlatıcı) servisi arayüzü.
abstract class DonationReminderService {
  Future<void> initialize();

  /// [eligibleAtUtc] tarihinde yerel saat [reminderHour]'da bildirim planlar.
  /// Tarih geçmişteyse mevcut hatırlatıcıyı iptal eder.
  Future<Result<DateTime?>> scheduleNextDonationReminder({
    required DateTime eligibleAtUtc,
    required String title,
    required String body,
    int reminderHour = 10,
  });

  Future<Result<void>> cancelNextDonationReminder();
}

/// Sonraki uygun bağış tarihini cihaz takvimine ekleyen servis arayüzü.
abstract class CalendarExportService {
  Future<Result<bool>> addNextDonationToCalendar({
    required DateTime eligibleAtUtc,
    required String title,
    required String description,
  });
}

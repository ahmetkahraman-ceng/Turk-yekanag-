import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/features/notifications/domain/app_notification.dart';

/// Uygulama içi bildirim merkezi state notifier'ı (okundu/okunmadı yönetimi).
class NotificationCenterNotifier extends StateNotifier<List<AppNotification>> {
  NotificationCenterNotifier({List<AppNotification>? initialNotifications})
      : super(initialNotifications ?? _defaultSeedNotifications());

  static List<AppNotification> _defaultSeedNotifications() {
    final now = DateTime.now().toUtc();
    return <AppNotification>[
      AppNotification(
        id: 'notif-1',
        title: 'Acil A Rh(+) Eritrosit İhtiyacı',
        body: 'Ankara Bilkent Şehir Hastanesi — Yakınınızda uyumlu acil talep açıldı.',
        createdAt: now.subtract(const Duration(minutes: 12)),
        isRead: false,
        requestId: 'req-seed-1',
        isCritical: true,
      ),
      AppNotification(
        id: 'notif-2',
        title: 'Eşleşme Onayı Bilgilendirmesi',
        body: 'Yardım teklifiniz talep sahibi tarafından görüntülendi.',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
        requestId: 'req-seed-2',
      ),
    ];
  }

  void markAsRead(String notificationId) {
    state = [
      for (final item in state)
        if (item.id == notificationId) item.copyWith(isRead: true) else item,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final item in state) item.copyWith(isRead: true),
    ];
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }
}

final notificationCenterProvider =
    StateNotifierProvider<NotificationCenterNotifier, List<AppNotification>>(
  (ref) => NotificationCenterNotifier(),
);

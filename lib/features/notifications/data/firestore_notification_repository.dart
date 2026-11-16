import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/mock/mock_data.dart';
import 'package:turkiye_kan_agi/features/notifications/domain/app_notification.dart';

/// Uygulama içi bildirim merkezi state notifier'ı (okundu/okunmadı/silme yönetimi).
class NotificationCenterNotifier extends StateNotifier<List<AppNotification>> {
  NotificationCenterNotifier({List<AppNotification>? initialNotifications})
      : super(initialNotifications ?? _defaultSeedNotifications());

  static List<AppNotification> _defaultSeedNotifications() {
    return MockData.notifications;
  }

  List<AppNotification> get currentItems => state;

  void markAsRead(String notificationId) {
    state = [
      for (final item in state)
        if (item.id == notificationId) item.copyWith(isRead: true) else item,
    ];
  }

  void toggleRead(String notificationId) {
    state = [
      for (final item in state)
        if (item.id == notificationId)
          item.copyWith(isRead: !item.isRead)
        else
          item,
    ];
  }

  void removeNotification(String notificationId) {
    state = state.where((item) => item.id != notificationId).toList();
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

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationCenterProvider);
  return list.where((n) => !n.isRead).length;
});

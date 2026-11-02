import 'package:flutter/foundation.dart';

/// Uygulama içi bildirim modeli.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.requestId,
    this.isCritical = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? requestId;
  final bool isCritical;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      requestId: requestId,
      isCritical: isCritical,
    );
  }
}

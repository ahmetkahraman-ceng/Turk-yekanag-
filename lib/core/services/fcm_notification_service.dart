import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';

/// Android bildirim kanalı sabitleri.
abstract final class AndroidNotificationChannels {
  static const String urgentChannelId = 'urgent_blood_channel';
  static const String urgentChannelName = 'Acil Kan Çağrıları';
  static const String normalChannelId = 'normal_blood_channel';
  static const String normalChannelName = 'Standart Kan ve Eşleşme Bildirimleri';
}

/// FCM (Firebase Cloud Messaging) izin, token yönetimi ve bildirim yönlendirme servisi.
class FcmNotificationService {
  FcmNotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging;

  final FirebaseMessaging? _messaging;
  String? _cachedToken;

  String? get cachedToken => _cachedToken;

  /// iOS/Android bildirim izinlerini ister ve FCM token'ı alır.
  Future<String?> initializeAndGetToken() async {
    final msg = _messaging;
    if (msg == null) return _cachedToken;
    try {
      await msg.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );
      _cachedToken = await msg.getToken();
      return _cachedToken;
    } catch (_) {
      return null;
    }
  }

  /// Arka planda veya kapalıyken tıklanan FCM bildiriminin veri yükünden (`data`)
  /// açılması gereken uygulama içi rotayı çözümler.
  static String? resolveRouteFromPayload(Map<String, dynamic> data) {
    final requestId = data['requestId'] as String?;
    if (requestId != null && requestId.trim().isNotEmpty) {
      return '${AppRoutes.requests}/${requestId.trim()}';
    }
    final route = data['route'] as String?;
    if (route != null && route.trim().isNotEmpty) {
      return route.trim();
    }
    return null;
  }
}

final fcmNotificationServiceProvider = Provider<FcmNotificationService>((ref) {
  return FcmNotificationService();
});

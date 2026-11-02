import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aktif oturum açmış kullanıcının UID bilgisini tutan sağlayıcı.
final currentUserIdStateProvider = StateProvider<String?>((ref) {
  return 'default-authenticated-user';
});

/// Kullanıcının profil sihirbazını tamamlayıp tamamlamadığını tutan sağlayıcı.
final profileCompletedStateProvider = StateProvider<bool>((ref) {
  return true;
});

/// Kimlik doğrulama durumu sağlayıcısı (Auth Guard için).
final isAuthenticatedProvider = Provider<bool>((ref) {
  final uid = ref.watch(currentUserIdStateProvider);
  return uid != null && uid.isNotEmpty;
});

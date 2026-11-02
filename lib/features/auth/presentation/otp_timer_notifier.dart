import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SMS OTP yeniden gönderme geri sayım sayacı (varsayılan 60 saniye).
class OtpTimerNotifier extends AutoDisposeNotifier<int> {
  Timer? _timer;

  static const int defaultDurationSeconds = 60;

  @override
  int build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    _startCountdown(defaultDurationSeconds);
    return defaultDurationSeconds;
  }

  void restart({int seconds = defaultDurationSeconds}) {
    _startCountdown(seconds);
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    state = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state <= 1) {
        state = 0;
        timer.cancel();
      } else {
        state = state - 1;
      }
    });
  }
}

final otpTimerProvider = AutoDisposeNotifierProvider<OtpTimerNotifier, int>(
  OtpTimerNotifier.new,
);

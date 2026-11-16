import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';

/// Ek paket kullanmadan CustomPainter ile çizilen hafif kutlama konfetisi.
/// MediaQuery.disableAnimations açıksa statik dekoratif noktalar gösterir.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    required this.child,
    super.key,
    this.isActive = true,
  });

  final Widget child;
  final bool isActive;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;
    final disableAnim = AppMotion.isAnimationsDisabled(context);

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: disableAnim
                  ? const CustomPaint(
                      painter: _ConfettiPainter(progress: 0.45),
                    )
                  : AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => CustomPaint(
                        painter: _ConfettiPainter(progress: _controller.value),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  final double progress;

  static const List<Color> _palette = [
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;
    final fade = (1.0 - ((progress - 0.65) / 0.35).clamp(0.0, 1.0));
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 28; i++) {
      final seed = (i + 1) * 37;
      final xRatio = ((seed * 13) % 100) / 100.0;
      final speed = 0.55 + ((seed % 5) * 0.12);
      final drift = math.sin(progress * math.pi * 2 + i) * 18.0;
      final x = size.width * xRatio + drift;
      final y = (size.height * 0.08) +
          (size.height * 0.75 * progress * speed) % (size.height * 0.85);

      paint.color = _palette[i % _palette.length].withValues(alpha: 0.75 * fade);
      if (i.isEven) {
        canvas.drawCircle(Offset(x, y), 5.0 + (i % 3), paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 10, height: 6),
            const Radius.circular(3),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

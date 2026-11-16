import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';

/// CustomPainter ile çizilen animasyonlu dairesel geri sayım / uygunluk halkası.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    required this.progress,
    required this.centerText,
    super.key,
    this.subtitleText,
    this.size = 120.0,
    this.strokeWidth = 10.0,
    this.isEligible = false,
  });

  /// 0.0 ile 1.0 arasında ilerleme oranı.
  final double progress;
  final String centerText;
  final String? subtitleText;
  final double size;
  final double strokeWidth;
  final bool isEligible;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = isEligible ? AppColors.success : scheme.primary;
    final trackColor = scheme.surfaceContainerHighest;
    final dur = AppMotion.resolveDuration(context, AppMotion.slow);

    return Semantics(
      label: '$centerText ${subtitleText ?? ""}'.trim(),
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
          duration: dur,
          curve: AppMotion.outCurve,
          builder: (context, animatedValue, child) {
            return SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _CountdownRingPainter(
                  progress: animatedValue,
                  activeColor: activeColor,
                  trackColor: trackColor,
                  strokeWidth: strokeWidth,
                ),
                child: child,
              ),
            );
          },
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(strokeWidth + 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEligible)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                  Text(
                    centerText,
                    textAlign: TextAlign.center,
                    style: (size >= 110
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.labelMedium)
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (subtitleText != null)
                    Text(
                      subtitleText!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  const _CountdownRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

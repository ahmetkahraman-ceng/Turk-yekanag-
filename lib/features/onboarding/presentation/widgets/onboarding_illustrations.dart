import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';

enum OnboardingIllustrationType { drop, mapPin, handshake, shield }

/// Dış görsel kullanmadan CustomPainter ile marka renklerinde çizilen
/// sakin ve soyut 4 onboarding illüstrasyonu.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    required this.type,
    super.key,
    this.parallaxOffset = 0.0,
    this.size = 180.0,
  });

  final OnboardingIllustrationType type;
  final double parallaxOffset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(parallaxOffset * 28, 0),
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _OnboardingIllustrationPainter(
              type: type,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingIllustrationPainter extends CustomPainter {
  const _OnboardingIllustrationPainter({
    required this.type,
    required this.isDark,
  });

  final OnboardingIllustrationType type;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Arka plan yumuşak hale
    final haloPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.44, haloPaint);

    final innerHaloPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.16)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.32, innerHaloPaint);

    final primaryPaint = Paint()
      ..color = isDark ? AppColors.darkPrimary : AppColors.primary
      ..style = PaintingStyle.fill;

    final whiteStroke = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case OnboardingIllustrationType.drop:
        final path = Path()
          ..moveTo(w * 0.50, h * 0.22)
          ..cubicTo(w * 0.58, h * 0.34, w * 0.72, h * 0.48, w * 0.72, h * 0.61)
          ..cubicTo(w * 0.72, h * 0.74, w * 0.62, h * 0.80, w * 0.50, h * 0.80)
          ..cubicTo(w * 0.38, h * 0.80, w * 0.28, h * 0.74, w * 0.28, h * 0.61)
          ..cubicTo(w * 0.28, h * 0.48, w * 0.42, h * 0.34, w * 0.50, h * 0.22)
          ..close();
        canvas.drawPath(path, primaryPaint);
        canvas.drawCircle(
          Offset(w * 0.50, h * 0.60),
          w * 0.06,
          Paint()..color = AppColors.surface,
        );

      case OnboardingIllustrationType.mapPin:
        final pinPath = Path()
          ..moveTo(w * 0.50, h * 0.78)
          ..cubicTo(w * 0.34, h * 0.60, w * 0.30, h * 0.48, w * 0.30, h * 0.41)
          ..arcToPoint(
            Offset(w * 0.70, h * 0.41),
            radius: Radius.circular(w * 0.20),
          )
          ..cubicTo(w * 0.70, h * 0.48, w * 0.66, h * 0.60, w * 0.50, h * 0.78)
          ..close();
        canvas.drawPath(pinPath, primaryPaint);
        canvas.drawCircle(
          Offset(w * 0.50, h * 0.42),
          w * 0.08,
          Paint()..color = AppColors.surface,
        );

      case OnboardingIllustrationType.handshake:
        // İki kenetlenen halkalı kalp/el sıkışma soyut sembolü
        canvas.drawCircle(Offset(w * 0.42, h * 0.50), w * 0.16, primaryPaint);
        canvas.drawCircle(
          Offset(w * 0.58, h * 0.50),
          w * 0.16,
          Paint()..color = AppColors.primaryDark,
        );
        canvas.drawArc(
          Rect.fromCenter(center: center, width: w * 0.30, height: h * 0.22),
          0.2,
          2.7,
          false,
          whiteStroke,
        );

      case OnboardingIllustrationType.shield:
        final shield = Path()
          ..moveTo(w * 0.50, h * 0.24)
          ..lineTo(w * 0.70, h * 0.32)
          ..cubicTo(w * 0.70, h * 0.54, w * 0.64, h * 0.68, w * 0.50, h * 0.78)
          ..cubicTo(w * 0.36, h * 0.68, w * 0.30, h * 0.54, w * 0.30, h * 0.32)
          ..close();
        canvas.drawPath(shield, primaryPaint);
        final check = Path()
          ..moveTo(w * 0.42, h * 0.51)
          ..lineTo(w * 0.48, h * 0.57)
          ..lineTo(w * 0.60, h * 0.44);
        canvas.drawPath(check, whiteStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingIllustrationPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.isDark != isDark;
  }
}

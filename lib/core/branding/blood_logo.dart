import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';

/// Türkiye Kan Ağı marka logosu.
/// CustomPainter ile kan damlası (üstü sivri, altı yuvarlak, kübik bezier,
/// dikey gradyan primaryLight -> primary -> primaryDark, sol üstte parlama)
/// ve içinde kalp formu oluşturan 3 noktalı dayanışma ağı çizer.
class BloodLogo extends StatelessWidget {
  const BloodLogo({
    super.key,
    this.size = 96.0,
    this.progress = 1.0,
    this.monochrome = false,
    this.semanticLabel,
  });

  final double size;

  /// 0.0 ile 1.0 arasında ağ noktaları ve çizgilerinin kademeli çizim ilerlemesi.
  final double progress;

  /// Beyaz/tek renk varyantı.
  final bool monochrome;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: BloodLogoPainter(
            progress: progress.clamp(0.0, 1.0),
            monochrome: monochrome,
          ),
        ),
      ),
    );
  }
}

class BloodLogoPainter extends CustomPainter {
  const BloodLogoPainter({
    this.progress = 1.0,
    this.monochrome = false,
  });

  final double progress;
  final bool monochrome;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Kan damlası dış yolu (üstü sivri, altı yuvarlak kübik bezier)
    final dropPath = Path()
      ..moveTo(w * 0.50, h * 0.06)
      ..cubicTo(
        w * 0.56,
        h * 0.20,
        w * 0.84,
        h * 0.46,
        w * 0.84,
        h * 0.65,
      )
      ..cubicTo(
        w * 0.84,
        h * 0.84,
        w * 0.69,
        h * 0.94,
        w * 0.50,
        h * 0.94,
      )
      ..cubicTo(
        w * 0.31,
        h * 0.94,
        w * 0.16,
        h * 0.84,
        w * 0.16,
        h * 0.65,
      )
      ..cubicTo(
        w * 0.16,
        h * 0.46,
        w * 0.44,
        h * 0.20,
        w * 0.50,
        h * 0.06,
      )
      ..close();

    final dropPaint = Paint()..style = PaintingStyle.fill;
    if (monochrome) {
      dropPaint.color = AppColors.surface;
    } else {
      dropPaint.shader = ui.Gradient.linear(
        Offset(w * 0.5, h * 0.06),
        Offset(w * 0.5, h * 0.94),
        const [
          AppColors.primaryLight,
          AppColors.primary,
          AppColors.primaryDark,
        ],
        const [0.0, 0.55, 1.0],
      );
    }

    canvas.drawPath(dropPath, dropPaint);

    // 2. Sol üst yarı saydam beyaz parlama
    final highlightPath = Path()
      ..moveTo(w * 0.44, h * 0.22)
      ..cubicTo(
        w * 0.33,
        h * 0.38,
        w * 0.25,
        h * 0.52,
        w * 0.26,
        h * 0.64,
      )
      ..cubicTo(
        w * 0.29,
        h * 0.54,
        w * 0.36,
        h * 0.40,
        w * 0.46,
        h * 0.26,
      )
      ..close();

    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (monochrome ? AppColors.primary : AppColors.surface)
          .withValues(alpha: 0.28);
    canvas.drawPath(highlightPath, highlightPaint);

    if (progress <= 0.0) return;

    // 3. İçeride kalp şekli oluşturan 3 nokta ve ağ çizgileri
    // Üst sol, üst sağ ve alt orta nokta
    final pLeft = Offset(w * 0.36, h * 0.56);
    final pRight = Offset(w * 0.64, h * 0.56);
    final pBottom = Offset(w * 0.50, h * 0.77);

    final fgColor = monochrome ? AppColors.primary : AppColors.surface;

    // Çizgiler (progress 0.3 -> 1.0 arasında kademeli çizilir)
    final lineProgress = ((progress - 0.25) / 0.75).clamp(0.0, 1.0);
    if (lineProgress > 0) {
      final linePaint = Paint()
        ..color = fgColor.withValues(alpha: 0.88)
        ..strokeWidth = (w * 0.028).clamp(1.5, 6.0)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Sol -> Alt çizgi
      final seg1 = (lineProgress * 3).clamp(0.0, 1.0);
      if (seg1 > 0) {
        canvas.drawLine(pLeft, Offset.lerp(pLeft, pBottom, seg1)!, linePaint);
      }
      // Sağ -> Alt çizgi
      final seg2 = ((lineProgress - 0.33) * 3).clamp(0.0, 1.0);
      if (seg2 > 0) {
        canvas.drawLine(pRight, Offset.lerp(pRight, pBottom, seg2)!, linePaint);
      }
      // Sol -> Sağ üst hafif kavisli bağ
      final seg3 = ((lineProgress - 0.66) * 3).clamp(0.0, 1.0);
      if (seg3 > 0) {
        final arcPath = Path()
          ..moveTo(pLeft.dx, pLeft.dy)
          ..quadraticBezierTo(
            w * 0.50,
            h * 0.49,
            ui.lerpDouble(pLeft.dx, pRight.dx, seg3)!,
            ui.lerpDouble(pLeft.dy, pRight.dy, seg3)!,
          );
        canvas.drawPath(arcPath, linePaint);
      }
    }

    // Noktalar (progress 0.0 -> 0.45 arasında sırayla belirir)
    final nodeRadius = (w * 0.052).clamp(2.5, 14.0);
    final nodePaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.fill;

    final n1Scale = (progress / 0.15).clamp(0.0, 1.0);
    if (n1Scale > 0) {
      canvas.drawCircle(pLeft, nodeRadius * n1Scale, nodePaint);
    }
    final n2Scale = ((progress - 0.12) / 0.15).clamp(0.0, 1.0);
    if (n2Scale > 0) {
      canvas.drawCircle(pRight, nodeRadius * n2Scale, nodePaint);
    }
    final n3Scale = ((progress - 0.24) / 0.15).clamp(0.0, 1.0);
    if (n3Scale > 0) {
      canvas.drawCircle(pBottom, nodeRadius * 1.12 * n3Scale, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BloodLogoPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.monochrome != monochrome;
  }
}

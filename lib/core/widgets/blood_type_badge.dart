import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_typography.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

enum BloodBadgeSize { s, m, l }

enum BloodBadgeShape { drop, circle }

/// 8 kan grubu için tutarlı, yüksek kontrastlı damla/yuvarlak rozet.
class BloodTypeBadge extends StatelessWidget {
  const BloodTypeBadge({
    required this.bloodType,
    super.key,
    this.size = BloodBadgeSize.m,
    this.shape = BloodBadgeShape.drop,
    this.isSelected = false,
  });

  final BloodType bloodType;
  final BloodBadgeSize size;
  final BloodBadgeShape shape;
  final bool isSelected;

  double get _dimension => switch (size) {
        BloodBadgeSize.s => 38.0,
        BloodBadgeSize.m => 52.0,
        BloodBadgeSize.l => 68.0,
      };

  double get _fontSize => switch (size) {
        BloodBadgeSize.s => 13.0,
        BloodBadgeSize.m => 16.0,
        BloodBadgeSize.l => 21.0,
      };

  @override
  Widget build(BuildContext context) {
    final isNeg = bloodType.code.contains('-');
    final bgColor = isNeg ? AppColors.primaryDark : AppColors.primary;

    return Semantics(
      label: 'Kan grubu ${bloodType.code}',
      child: RepaintBoundary(
        child: SizedBox(
          width: _dimension,
          height: _dimension,
          child: CustomPaint(
            painter: _BloodBadgePainter(
              color: bgColor,
              shape: shape,
              isSelected: isSelected,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: shape == BloodBadgeShape.drop ? _dimension * 0.10 : 0,
                ),
                child: Text(
                  bloodType.code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: AppColors.onPrimary,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BloodBadgePainter extends CustomPainter {
  const _BloodBadgePainter({
    required this.color,
    required this.shape,
    required this.isSelected,
  });

  final Color color;
  final BloodBadgeShape shape;
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (shape == BloodBadgeShape.circle) {
      final center = Offset(size.width / 2, size.height / 2);
      canvas.drawCircle(center, size.width / 2, paint);
      if (isSelected) {
        final borderPaint = Paint()
          ..color = AppColors.onPrimary
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, size.width / 2 - 2, borderPaint);
      }
      return;
    }

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..cubicTo(w * 0.62, h * 0.22, w * 0.92, h * 0.48, w * 0.92, h * 0.66)
      ..cubicTo(w * 0.92, h * 0.87, w * 0.74, h * 0.96, w * 0.50, h * 0.96)
      ..cubicTo(w * 0.26, h * 0.96, w * 0.08, h * 0.87, w * 0.08, h * 0.66)
      ..cubicTo(w * 0.08, h * 0.48, w * 0.38, h * 0.22, w * 0.50, h * 0.04)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BloodBadgePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shape != shape ||
        oldDelegate.isSelected != isSelected;
  }
}

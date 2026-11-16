import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';

/// Aşama 8: Ek chart paketi olmadan CustomPainter ile il bazlı sütun grafik ve 30 gün çizgi grafik.
class AdminChartsRow extends StatelessWidget {
  const AdminChartsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: 340,
          height: 210,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İl Bazlı Açık Talepler',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Expanded(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ProvinceBarChartPainter(),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 340,
          height: 210,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Son 30 Gün Karşılanan Talepler',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Expanded(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ThirtyDayLineChartPainter(),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProvinceBarChartPainter extends CustomPainter {
  const _ProvinceBarChartPainter();

  static const List<double> _values = [0.9, 0.72, 0.55, 0.4, 0.3];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final barWidth = size.width / (_values.length * 2);
    for (var i = 0; i < _values.length; i++) {
      final left = (i * 2 + 0.5) * barWidth;
      final barHeight = size.height * _values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThirtyDayLineChartPainter extends CustomPainter {
  const _ThirtyDayLineChartPainter();

  static const List<double> _points = [
    0.25,
    0.38,
    0.34,
    0.52,
    0.61,
    0.58,
    0.76,
    0.88,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final x = (size.width / (_points.length - 1)) * i;
      final y = size.height * (1 - _points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

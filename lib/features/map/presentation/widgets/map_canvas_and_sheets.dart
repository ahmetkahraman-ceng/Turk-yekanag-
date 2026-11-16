import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/mock/donation_center.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/widgets/request_card.dart';

/// Yol tarifi seçici Bottom Sheet (Google Maps / Yandex / Apple Maps).
class DirectionsPickerSheet extends StatelessWidget {
  const DirectionsPickerSheet({
    required this.destinationName,
    super.key,
  });

  final String destinationName;

  static Future<void> show(BuildContext context, String destinationName) {
    return AppBottomSheet.show<void>(
      context: context,
      builder: (_) => DirectionsPickerSheet(destinationName: destinationName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (Icons.map_rounded, l10n.directionsGoogleMaps),
      (Icons.navigation_rounded, l10n.directionsYandexNavi),
      (Icons.explore_rounded, l10n.directionsAppleMaps),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.directionsSheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            destinationName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final opt in options)
            ListTile(
              leading: Icon(opt.$1, color: Theme.of(context).colorScheme.primary),
              title: Text(opt.$2),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () {
                Navigator.of(context).pop();
                AppSnackbar.show(
                  context,
                  message: '${opt.$2} — $destinationName',
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Pin'e dokunulunca gösterilen DraggableScrollableSheet özet kartı.
class MapPinSummarySheet extends StatelessWidget {
  const MapPinSummarySheet({
    super.key,
    this.request,
    this.center,
    required this.onClose,
  });

  final BloodRequest? request;
  final DonationCenter? center;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.36,
      minChildSize: 0.24,
      maxChildSize: 0.65,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.bottomSheetBorder,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request != null
                        ? l10n.requestDetailTitle
                        : (center?.isMobileUnit == true
                            ? l10n.centerMobileUnitTitle
                            : l10n.mapFilterCenters),
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              if (request != null) ...[
                RequestCard(
                  request: request!,
                  enableHero: false,
                  onTap: () =>
                      context.push('${AppRoutes.requests}/${request!.id}'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: l10n.requestDirectionsButton,
                        variant: AppButtonVariant.secondary,
                        icon: Icons.directions_rounded,
                        onPressed: () => DirectionsPickerSheet.show(
                          context,
                          request!.hospital.name,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppButton(
                        label: l10n.urgentHeadsUpAction,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push(
                          '${AppRoutes.requests}/${request!.id}',
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (center != null) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            center!.isMobileUnit
                                ? Icons.directions_bus_rounded
                                : Icons.local_hospital_rounded,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              center!.name,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          if (center!.isMobileUnit)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.info,
                                borderRadius: AppRadius.chipBorder,
                              ),
                              child: Text(
                                l10n.centerMobileUnitBadge,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.onInfo,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${center!.district} / ${center!.province} • ${center!.workingHours} (${center!.isOpenNow ? l10n.centerOpenNow : l10n.centerClosedNow})',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'Tel: ${center!.phone}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.requestDirectionsButton,
                  icon: Icons.directions_rounded,
                  onPressed: () =>
                      DirectionsPickerSheet.show(context, center!.name),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// API anahtarı olmadığında veya test ortamında çökmeden çalışan,
/// karanlık/aydınlık tema, kümeleme, mavi konum noktası ve özel pin destekli etkileşimli harita yüzeyi.
class InteractiveMapCanvas extends StatelessWidget {
  const InteractiveMapCanvas({
    required this.requests,
    required this.centers,
    required this.onSelectRequest,
    required this.onSelectCenter,
    super.key,
  });

  final List<BloodRequest> requests;
  final List<DonationCenter> centers;
  final ValueChanged<BloodRequest> onSelectRequest;
  final ValueChanged<DonationCenter> onSelectCenter;

  Color _pinColorForUrgency(RequestUrgency urgency) {
    return switch (urgency) {
      RequestUrgency.critical => AppColors.primary,
      RequestUrgency.today => AppColors.warning,
      RequestUrgency.thisWeek => AppColors.neutralTag,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleReqs = requests.take(6).toList();
    final visibleCenters = centers.take(4).toList();

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapGridPainter(isDark: isDark),
                ),
              ),
              // Kullanıcı mavi konum noktası
              Positioned(
                left: w * 0.48,
                top: h * 0.46,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.info.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              // Kümeleme (Cluster) rozeti
              if (requests.length > 6)
                Positioned(
                  left: w * 0.72,
                  top: h * 0.22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: AppRadius.chipBorder,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '+${requests.length - 6}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              // Talep pin'leri
              for (var i = 0; i < visibleReqs.length; i++)
                Positioned(
                  left: (w * (0.14 + (i * 0.13) % 0.70)).clamp(12, w - 72),
                  top: (h * (0.18 + ((i * 23) % 55) / 100)).clamp(12, h - 56),
                  child: GestureDetector(
                    key: Key('map_request_pin_${visibleReqs[i].id}'),
                    onTap: () => onSelectRequest(visibleReqs[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _pinColorForUrgency(visibleReqs[i].urgency),
                        borderRadius: AppRadius.chipBorder,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bloodtype_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            visibleReqs[i].bloodType.code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Bağış merkezi & Gezici araç pin'leri (Mavi)
              for (var j = 0; j < visibleCenters.length; j++)
                Positioned(
                  left: (w * (0.20 + (j * 0.21) % 0.68)).clamp(12, w - 80),
                  top: (h * (0.55 + ((j * 17) % 30) / 100)).clamp(12, h - 56),
                  child: GestureDetector(
                    key: Key('map_center_pin_${visibleCenters[j].id}'),
                    onTap: () => onSelectCenter(visibleCenters[j]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: AppRadius.chipBorder,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            visibleCenters[j].isMobileUnit
                                ? Icons.directions_bus_rounded
                                : Icons.local_hospital_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          if (visibleCenters[j].isMobileUnit) ...[
                            const SizedBox(width: 3),
                            Text(
                              context.l10n.centerMobileUnitBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? const Color(0xFF1F1616) : const Color(0xFFF3ECE9);
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF342424) : const Color(0xFFE4D8D4)
      ..strokeWidth = 2.0;

    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

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
import 'package:turkiye_kan_agi/features/map/presentation/widgets/real_map_tile_canvas.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/widgets/request_card.dart';

export 'package:turkiye_kan_agi/features/map/presentation/widgets/real_map_tile_canvas.dart'
    show RealMapController, RealMapTileCanvas;

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
    required this.onClose,
    super.key,
    this.request,
    this.center,
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

/// Geriye dönük uyumluluk sarmalayıcısı: gerçek harita karolarını ve koordinatlarını çizen `RealMapTileCanvas` kullanır.
class InteractiveMapCanvas extends StatelessWidget {
  const InteractiveMapCanvas({
    required this.requests,
    required this.centers,
    required this.onSelectRequest,
    required this.onSelectCenter,
    super.key,
    this.controller,
  });

  final List<BloodRequest> requests;
  final List<DonationCenter> centers;
  final ValueChanged<BloodRequest> onSelectRequest;
  final ValueChanged<DonationCenter> onSelectCenter;
  final RealMapController? controller;

  @override
  Widget build(BuildContext context) {
    return RealMapTileCanvas(
      requests: requests,
      centers: centers,
      onSelectRequest: onSelectRequest,
      onSelectCenter: onSelectCenter,
      controller: controller,
    );
  }
}

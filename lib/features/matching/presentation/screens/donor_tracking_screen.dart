import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_shadows.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_chip.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/step_and_progress.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';

/// Bağışçı Takip Ekranı:
/// StepIndicator (Teklif gönderildi -> Onaylandı -> Yoldayım -> Vardım -> Bağış yaptım)
/// Sonraki eylem tek büyük buton; onaylanınca "Ara", "WhatsApp",
/// hazır hızlı mesaj çipleri ("15 dakikada oradayım", "Hangi servis?", "Geldim, neredesiniz?"), yol tarifi.
class DonorTrackingScreen extends StatefulWidget {
  const DonorTrackingScreen({
    required this.request,
    super.key,
  });

  final BloodRequest request;

  @override
  State<DonorTrackingScreen> createState() => _DonorTrackingScreenState();
}

class _DonorTrackingScreenState extends State<DonorTrackingScreen> {
  int _stepIndex = 1; // Varsayılan olarak onaylanmış (1) gösterimiyle başlar
  String? _selectedQuickMessage;

  void _advanceStep() {
    if (_stepIndex < 4) {
      setState(() => _stepIndex++);
    } else {
      context.go(AppRoutes.celebration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final req = widget.request;

    final stepLabels = [
      l10n.donorStepOffered,
      l10n.donorStepApproved,
      l10n.donorStepOnWay,
      l10n.donorStepArrived,
      l10n.donorStepDonated,
    ];

    final nextButtonLabel = _stepIndex < 4
        ? stepLabels[_stepIndex + 1]
        : l10n.celebrationTitle;

    final quickMessages = [
      l10n.quickMsg15Min,
      l10n.quickMsgWhichWard,
      l10n.quickMsgArrivedWhere,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.donorTrackingTitle)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: AppShadows.bottomBarFor(theme.brightness),
          ),
          child: ResponsiveConstrainedBox(
            child: AppButton(
              key: const Key('donor_tracking_primary_button'),
              label: nextButtonLabel,
              icon: Icons.check_circle_outline_rounded,
              enableHaptic: true,
              onPressed: _advanceStep,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  StepIndicator(
                    totalSteps: 5,
                    currentStep: _stepIndex,
                    labels: stepLabels,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Row(
                      children: [
                        BloodTypeBadge(
                          bloodType: req.bloodType,
                          size: BloodBadgeSize.m,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.hospital.name,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                '${req.department} • ${req.hospital.district}/${req.hospital.province}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_stepIndex >= 1) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_open_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  l10n.matchingOfferApproved,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: l10n.matchingCallButton,
                                  variant: AppButtonVariant.secondary,
                                  icon: Icons.phone_rounded,
                                  onPressed: () {
                                    AppSnackbar.show(
                                      context,
                                      message: '+90 532 *** ** 44 aranıyor...',
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: AppButton(
                                  label: l10n.matchingWhatsAppButton,
                                  variant: AppButtonVariant.secondary,
                                  icon: Icons.chat_bubble_outline_rounded,
                                  onPressed: () {
                                    AppSnackbar.show(
                                      context,
                                      message: 'WhatsApp açılıyor...',
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppButton(
                            label: l10n.requestDirectionsButton,
                            variant: AppButtonVariant.text,
                            icon: Icons.directions_rounded,
                            onPressed: () => context.go(AppRoutes.map),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hızlı Mesaj Gönder',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              for (final msg in quickMessages)
                                AppChip(
                                  label: msg,
                                  selected: _selectedQuickMessage == msg,
                                  onSelected: (_) {
                                    setState(() => _selectedQuickMessage = msg);
                                    AppSnackbar.show(context, message: msg);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

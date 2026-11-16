import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/branding/blood_logo.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/confetti_overlay.dart';

/// Kutlama ekranı:
/// Tam ekran, kalp atışı animasyonlu damla, ConfettiOverlay,
/// "Bir hayata dokundun", kazanılan rozet kartı, "Paylaş" ve "Kapat", haptic.
/// `disableAnimations` açıkken statik çalışır.
class DonationCelebrationScreen extends StatefulWidget {
  const DonationCelebrationScreen({super.key});

  @override
  State<DonationCelebrationScreen> createState() =>
      _DonationCelebrationScreenState();
}

class _DonationCelebrationScreenState extends State<DonationCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 1.0,
      upperBound: 1.08,
    );
    HapticFeedback.mediumImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.isAnimationsDisabled(context)) {
      _pulseController.stop();
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final disableAnim = AppMotion.isAnimationsDisabled(context);

    return Scaffold(
      body: ConfettiOverlay(
        child: SafeArea(
          child: ResponsiveConstrainedBox(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: disableAnim
                        ? const BloodLogo(size: 96)
                        : ScaleTransition(
                            scale: _pulseController,
                            child: const BloodLogo(size: 96),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.celebrationTitle,
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.celebrationSubtitle,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.celebrationBadgeEarned,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                l10n.donationLivesSavedSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    key: const Key('celebration_share_button'),
                    label: l10n.requestShareButton,
                    icon: Icons.share_rounded,
                    enableHaptic: true,
                    onPressed: () {
                      AppSnackbar.show(
                        context,
                        message: l10n.requestShareCopiedMessage,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    key: const Key('celebration_close_button'),
                    label: l10n.commonClose,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.go(AppRoutes.donation),
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

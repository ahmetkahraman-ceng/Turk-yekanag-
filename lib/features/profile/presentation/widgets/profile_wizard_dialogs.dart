import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/confetti_overlay.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/widgets/onboarding_illustrations.dart';

/// Profil sihirbazı sonunda gösterilen Konum İzni açıklama görünümü.
class LocationPermissionExplainerView extends StatelessWidget {
  const LocationPermissionExplainerView({
    required this.onAllowLocation,
    required this.onSkipLocation,
    super.key,
  });

  final VoidCallback onAllowLocation;
  final VoidCallback onSkipLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: OnboardingIllustration(
              type: OnboardingIllustrationType.mapPin,
              size: 140,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.locationPermissionTitle,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.locationPermissionSubtitle,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('allow_location_button'),
            label: l10n.locationPermissionAllowButton,
            icon: Icons.my_location_rounded,
            enableHaptic: true,
            onPressed: onAllowLocation,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            key: const Key('skip_location_button'),
            label: l10n.locationPermissionSkipButton,
            variant: AppButtonVariant.secondary,
            onPressed: onSkipLocation,
          ),
        ],
      ),
    );
  }
}

/// Profil sihirbazı sonunda gösterilen "Hazırsın" kutlama görünümü (ConfettiOverlay).
class ProfileReadyCelebrationView extends StatelessWidget {
  const ProfileReadyCelebrationView({
    required this.onFinish,
    super.key,
  });

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ConfettiOverlay(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: OnboardingIllustration(
                type: OnboardingIllustrationType.drop,
                size: 140,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.readyCelebrationTitle,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.readyCelebrationSubtitle,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.nonCommercialNotice,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('ready_celebration_finish_button'),
              label: l10n.readyCelebrationAction,
              enableHaptic: true,
              onPressed: onFinish,
            ),
          ],
        ),
      ),
    );
  }
}

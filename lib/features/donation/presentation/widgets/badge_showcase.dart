import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/branding/blood_logo.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';

class DonorBadgeItem {
  const DonorBadgeItem({
    required this.id,
    required this.title,
    required this.hint,
    required this.icon,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String hint;
  final IconData icon;
  final bool unlocked;
}

/// Rozet vitrini, rozet detay sheet'i ve paylaşılabilir bağış kartı önizlemesi.
class BadgeShowcaseSection extends StatelessWidget {
  const BadgeShowcaseSection({
    required this.donationCount,
    super.key,
  });

  final int donationCount;

  void _showBadgeDetailSheet(BuildContext context, DonorBadgeItem badge) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    AppBottomSheet.show<void>(
      context: context,
      builder: (ctx) => Padding(
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
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: badge.unlocked
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  badge.icon,
                  size: 36,
                  color: badge.unlocked
                      ? theme.colorScheme.primary
                      : AppColors.neutralTag,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              badge.title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              badge.hint,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            // Paylaşılabilir bağış kartı önizlemesi
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.cardBorder,
                ),
                child: Row(
                  children: [
                    const BloodLogo(size: 40, monochrome: true),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                          Text(
                            l10n.appTitle,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.requestShareButton,
              icon: Icons.share_rounded,
              onPressed: () {
                Navigator.of(ctx).pop();
                AppSnackbar.show(
                  context,
                  message: l10n.requestShareCopiedMessage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final badges = <DonorBadgeItem>[
      DonorBadgeItem(
        id: 'first_drop',
        title: l10n.badgeFirstDrop,
        hint: l10n.badgeFirstDropHint,
        icon: Icons.water_drop_rounded,
        unlocked: donationCount >= 1,
      ),
      DonorBadgeItem(
        id: 'emergency_responder',
        title: l10n.badgeEmergencyResponder,
        hint: l10n.badgeEmergencyResponderHint,
        icon: Icons.bolt_rounded,
        unlocked: true,
      ),
      DonorBadgeItem(
        id: 'regular_hero',
        title: l10n.badgeRegularHero,
        hint: l10n.badgeRegularHeroHint,
        icon: Icons.workspace_premium_rounded,
        unlocked: donationCount >= 3,
      ),
      DonorBadgeItem(
        id: 'apheresis_star',
        title: l10n.badgeApheresisStar,
        hint: l10n.badgeApheresisStarHint,
        icon: Icons.auto_awesome_rounded,
        unlocked: false,
      ),
      DonorBadgeItem(
        id: 'community_builder',
        title: l10n.badgeCommunityBuilder,
        hint: l10n.badgeCommunityBuilderHint,
        icon: Icons.groups_rounded,
        unlocked: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.badgesSectionTitle),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final b = badges[index];
              return SizedBox(
                width: 112,
                child: AppCard(
                  key: Key('badge_card_${b.id}'),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  onTap: () => _showBadgeDetailSheet(context, b),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        b.unlocked ? b.icon : Icons.lock_outline_rounded,
                        size: 28,
                        color: b.unlocked
                            ? theme.colorScheme.primary
                            : AppColors.neutralTag,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        b.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: b.unlocked
                              ? theme.colorScheme.onSurface
                              : AppColors.neutralTag,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

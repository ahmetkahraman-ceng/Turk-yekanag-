import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/feature_placeholder_view.dart';
import 'package:turkiye_kan_agi/core/widgets/loading_skeleton.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';

/// Bağış öncesi ve sonrası öneriler ekranı.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class DonationTipsScreen extends StatelessWidget {
  const DonationTipsScreen({
    super.key,
    this.viewState,
  });

  final ScreenViewState? viewState;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final beforeItems = <String>[
      l10n.donationTipsBefore1,
      l10n.donationTipsBefore2,
      l10n.donationTipsBefore3,
    ];
    final afterItems = <String>[
      l10n.donationTipsAfter1,
      l10n.donationTipsAfter2,
      l10n.donationTipsAfter3,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.donationTipsTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: switch (viewState) {
              ScreenViewState.loading => const LoadingSkeleton(itemCount: 4),
              ScreenViewState.error => ErrorState(
                  message: l10n.commonErrorMessage,
                  onRetry: () {},
                ),
              ScreenViewState.empty => EmptyState(
                  title: l10n.donationEmptyTitle,
                  subtitle: l10n.donationEmptySubtitle,
                ),
              null => ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    Card(
                      color: theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          l10n.donationTipsMedicalNote,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _TipsSectionCard(
                      sectionKey: const Key('tips_before_section'),
                      title: l10n.donationTipsBeforeTitle,
                      icon: Icons.wb_sunny_outlined,
                      items: beforeItems,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _TipsSectionCard(
                      sectionKey: const Key('tips_after_section'),
                      title: l10n.donationTipsAfterTitle,
                      icon: Icons.favorite_outline_rounded,
                      items: afterItems,
                    ),
                  ],
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _TipsSectionCard extends StatelessWidget {
  const _TipsSectionCard({
    required this.sectionKey,
    required this.title,
    required this.icon,
    required this.items,
  });

  final Key sectionKey;
  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: sectionKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

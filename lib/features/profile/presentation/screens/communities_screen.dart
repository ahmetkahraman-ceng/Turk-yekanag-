import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/core/widgets/tiles_and_selection_sheet.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.name,
    required this.city,
    required this.memberCount,
    this.bloodType,
  });

  final String id;
  final String name;
  final String city;
  final int memberCount;
  final BloodType? bloodType;
}

const List<CommunityGroup> _mockCommunities = [
  CommunityGroup(
    id: 'comm-ank-0neg',
    name: 'Ankara 0 Rh(-) Dayanışma Grubu',
    city: 'Ankara',
    memberCount: 412,
    bloodType: BloodType.oNeg,
  ),
  CommunityGroup(
    id: 'comm-ist-apheresis',
    name: 'İstanbul Aferez Gönüllüleri',
    city: 'İstanbul',
    memberCount: 1280,
  ),
  CommunityGroup(
    id: 'comm-izm-abneg',
    name: 'İzmir AB Rh(-) Nadir Kan Ağı',
    city: 'İzmir',
    memberCount: 195,
    bloodType: BloodType.abNeg,
  ),
  CommunityGroup(
    id: 'comm-ank-uni',
    name: 'Üniversite Kan Gönüllüleri',
    city: 'Ankara',
    memberCount: 845,
  ),
];

final joinedCommunitiesProvider =
    StateProvider<Set<String>>((ref) => {'comm-ank-0neg'});
final rareBloodOptInProvider = StateProvider<bool>((ref) => true);

/// Aşama 7.4: Şehir/kan grubu toplulukları, katıl/ayrıl, nadir kan ağı katılım kartı ve grup detayı.
class CommunitiesScreen extends ConsumerWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final joined = ref.watch(joinedCommunitiesProvider);
    final rareOptIn = ref.watch(rareBloodOptInProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.communitiesTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppCard(
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shield_moon_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                l10n.rareBloodNetworkTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SwitchTile(
                          value: rareOptIn,
                          onChanged: (v) =>
                              ref.read(rareBloodOptInProvider.notifier).state = v,
                          title: l10n.rareBloodNetworkTitle,
                          subtitle: l10n.rareBloodNetworkSubtitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionHeader(title: l10n.profileSectionCommunities),
                  for (final group in _mockCommunities)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CommunityGroupCard(
                        group: group,
                        isJoined: joined.contains(group.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityGroupCard extends ConsumerWidget {
  const _CommunityGroupCard({
    required this.group,
    required this.isJoined,
  });

  final CommunityGroup group;
  final bool isJoined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AppCard(
      onTap: () => _showGroupDetailSheet(context, group, isJoined, ref),
      child: Row(
        children: [
          if (group.bloodType != null)
            BloodTypeBadge(
              bloodType: group.bloodType!,
              size: BloodBadgeSize.s,
            )
          else
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.groups_rounded,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${group.city} • ${group.memberCount}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppButton(
            key: Key('community_toggle_${group.id}'),
            label: isJoined
                ? l10n.communityLeaveButton
                : l10n.communityJoinButton,
            variant: isJoined
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            isExpanded: false,
            onPressed: () {
              final current = {...ref.read(joinedCommunitiesProvider)};
              if (isJoined) {
                current.remove(group.id);
              } else {
                current.add(group.id);
              }
              ref.read(joinedCommunitiesProvider.notifier).state = current;
            },
          ),
        ],
      ),
    );
  }

  void _showGroupDetailSheet(
    BuildContext context,
    CommunityGroup group,
    bool isJoined,
    WidgetRef ref,
  ) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(group.name, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${group.city} • ${group.memberCount}',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.commonClose,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

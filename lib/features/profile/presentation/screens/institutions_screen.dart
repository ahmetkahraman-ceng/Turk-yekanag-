import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/core/widgets/status_and_urgency_tags.dart';

class CampaignEvent {
  const CampaignEvent({
    required this.id,
    required this.title,
    required this.institutionName,
    required this.location,
    required this.dateLabel,
    required this.participantCount,
    this.isVerified = true,
  });

  final String id;
  final String title;
  final String institutionName;
  final String location;
  final String dateLabel;
  final int participantCount;
  final bool isVerified;
}

const List<CampaignEvent> _initialCampaigns = [
  CampaignEvent(
    id: 'camp-1',
    title: 'ODTÜ Bahar Kan Bağışı Kampanyası',
    institutionName: 'Orta Doğu Teknik Üniversitesi Kızılay Topluluğu',
    location: 'Çankaya / Ankara',
    dateLabel: '24 Mayıs 2026 • 10:00 - 17:00',
    participantCount: 148,
  ),
  CampaignEvent(
    id: 'camp-2',
    title: 'Teknopark İstanbul Gönüllü Kan Günleri',
    institutionName: 'Teknopark İstanbul A.Ş.',
    location: 'Pendik / İstanbul',
    dateLabel: '29 Mayıs 2026 • 09:30 - 16:30',
    participantCount: 92,
  ),
];

final joinedCampaignIdsProvider =
    StateProvider<Set<String>>((ref) => <String>{});
final institutionPendingProvider = StateProvider<bool>((ref) => false);

/// Aşama 7.5: Kurum hesapları başvuru formu, onay bekliyor durumu,
/// doğrulanmış kurum rozeti, kampanya/etkinlik oluşturma ve listesi.
class InstitutionsScreen extends ConsumerStatefulWidget {
  const InstitutionsScreen({super.key});

  @override
  ConsumerState<InstitutionsScreen> createState() => _InstitutionsScreenState();
}

class _InstitutionsScreenState extends ConsumerState<InstitutionsScreen> {
  final _orgNameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _campaignTitleCtrl = TextEditingController();
  final _campaignLocationCtrl = TextEditingController();
  final List<CampaignEvent> _campaigns = List.of(_initialCampaigns);

  @override
  void dispose() {
    _orgNameCtrl.dispose();
    _contactCtrl.dispose();
    _campaignTitleCtrl.dispose();
    _campaignLocationCtrl.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (_orgNameCtrl.text.trim().isEmpty) return;
    ref.read(institutionPendingProvider.notifier).state = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.institutionPendingBanner)),
    );
  }

  void _addCampaign() {
    final title = _campaignTitleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _campaigns.insert(
        0,
        CampaignEvent(
          id: 'camp-${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          institutionName: _orgNameCtrl.text.trim().isEmpty
              ? 'Gönüllü Kurum'
              : _orgNameCtrl.text.trim(),
          location: _campaignLocationCtrl.text.trim().isEmpty
              ? 'Merkez'
              : _campaignLocationCtrl.text.trim(),
          dateLabel: 'Yakında • 10:00 - 17:00',
          participantCount: 1,
        ),
      );
      _campaignTitleCtrl.clear();
      _campaignLocationCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPending = ref.watch(institutionPendingProvider);
    final joinedIds = ref.watch(joinedCampaignIdsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.institutionTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.institutionCampaignsTab),
              Tab(text: l10n.institutionApplyTab),
            ],
          ),
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            if (isPending)
              Container(
                width: double.infinity,
                color: AppColors.warningLight,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(l10n.institutionPendingBanner)),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  ResponsiveConstrainedBox(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        for (final item in _campaigns)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _CampaignCard(
                              campaign: item,
                              isJoined: joinedIds.contains(item.id),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ResponsiveConstrainedBox(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(title: l10n.institutionApplyTab),
                          AppTextField(
                            key: const Key('institution_name_field'),
                            controller: _orgNameCtrl,
                            labelText: l10n.institutionTitle,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            key: const Key('institution_contact_field'),
                            controller: _contactCtrl,
                            labelText: l10n.profileSectionMyInfo,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            key: const Key('institution_apply_submit'),
                            label: l10n.institutionApplyTab,
                            onPressed: _submitApplication,
                          ),
                          const Divider(height: AppSpacing.xl),
                          SectionHeader(title: l10n.institutionCampaignsTab),
                          AppTextField(
                            key: const Key('campaign_title_field'),
                            controller: _campaignTitleCtrl,
                            labelText: l10n.institutionCampaignsTab,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            key: const Key('campaign_location_field'),
                            controller: _campaignLocationCtrl,
                            labelText: l10n.profileSectionLocationTravel,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            key: const Key('campaign_create_button'),
                            label: l10n.commonSave,
                            variant: AppButtonVariant.secondary,
                            onPressed: _addCampaign,
                          ),
                        ],
                      ),
                    ),
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

class _CampaignCard extends ConsumerWidget {
  const _CampaignCard({
    required this.campaign,
    required this.isJoined,
  });

  final CampaignEvent campaign;
  final bool isJoined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(campaign.title, style: theme.textTheme.titleMedium),
              ),
              if (campaign.isVerified)
                VerifiedBadge(label: l10n.institutionVerifiedBadge),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(campaign.institutionName, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${campaign.location} • ${campaign.dateLabel}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  key: Key('campaign_join_${campaign.id}'),
                  label: l10n.campaignJoinButton,
                  variant: isJoined
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.primary,
                  onPressed: () {
                    final set = {...ref.read(joinedCampaignIdsProvider)};
                    if (isJoined) {
                      set.remove(campaign.id);
                    } else {
                      set.add(campaign.id);
                    }
                    ref.read(joinedCampaignIdsProvider.notifier).state = set;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: l10n.donationAddToCalendarButton,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.donationAddToCalendarButton)),
                  );
                },
                icon: const Icon(Icons.calendar_month_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

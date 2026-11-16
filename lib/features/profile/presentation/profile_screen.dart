import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/l10n/locale_provider.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/theme/theme_mode_provider.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/core/widgets/status_and_urgency_tags.dart';
import 'package:turkiye_kan_agi/core/widgets/tiles_and_selection_sheet.dart';
import 'package:turkiye_kan_agi/features/auth/data/firebase_auth_repository.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

final travelModeCityProvider = StateProvider<String?>((ref) => null);

/// Aşama 7: Profil, ayarlar, seyahat modu, topluluklar, kurumsal, içerik,
/// iki adımlı yazarak doğrulamalı hesap silme ve JSON veri indirme ekranı.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isAvailable = true;

  Future<void> _onToggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(profileRepositoryProvider).updateAvailability(
          uid: uid,
          isAvailable: value,
        );
  }

  Future<void> _onExportData() async {
    final l10n = context.l10n;
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final result = await ref
        .read(profileRepositoryProvider)
        .exportUserDataJson(uid);
    if (!mounted) return;
    result.when(
      success: (jsonText) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.profileExportDataSuccessTitle),
            content: SingleChildScrollView(
              child: SelectableText(jsonText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.commonClose),
              ),
            ],
          ),
        );
      },
      failure: (_) {},
    );
  }

  Future<void> _onConfirmDeleteAccount() async {
    final l10n = context.l10n;
    final typeCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isMatch = typeCtrl.text.trim().toUpperCase() ==
              l10n.deleteAccountTypeConfirmWord.toUpperCase();
          return AlertDialog(
            title: Text(l10n.profileDeleteConfirmTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.profileDeleteConfirmBody),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('delete_account_confirm_input'),
                  controller: typeCtrl,
                  labelText: l10n.deleteAccountTypeConfirmHint,
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.commonCancel),
              ),
              ElevatedButton(
                key: const Key('confirm_delete_account_dialog_button'),
                onPressed: isMatch || typeCtrl.text.isEmpty
                    ? () => Navigator.of(ctx).pop(true)
                    : null,
                child: Text(l10n.profileDeleteConfirmAction),
              ),
            ],
          );
        },
      ),
    );
    typeCtrl.dispose();

    if (confirmed != true || !mounted) return;

    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(profileRepositoryProvider).deleteAccount(uid);
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    ref.read(currentUserIdStateProvider.notifier).state = null;
    ref.read(profileCompletedStateProvider.notifier).state = false;
    context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final travelCity = ref.watch(travelModeCityProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          if (travelCity != null)
            Container(
              width: double.infinity,
              color: AppColors.infoLight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.travelModeActiveBanner(travelCity, '17-24 May'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () =>
                        ref.read(travelModeCityProvider.notifier).state = null,
                  ),
                ],
              ),
            ),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            'AK',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ahmet K. (@gonullu_06)',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              VerifiedBadge(label: l10n.profileVerifiedPhone),
                            ],
                          ),
                        ),
                        const BloodTypeBadge(
                          bloodType: BloodType.aPos,
                          size: BloodBadgeSize.s,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: SwitchListTile(
                      key: const Key('available_to_donate_switch'),
                      value: _isAvailable,
                      onChanged: _onToggleAvailability,
                      title: Text(
                        l10n.profileAvailableSwitchTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(l10n.profileAvailableSwitchSubtitle),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionHeader(title: l10n.profileSectionMyInfo),
                  _NavTile(
                    icon: Icons.edit_outlined,
                    title: l10n.profileEditButton,
                    onTap: () => context.push(AppRoutes.profileSetup),
                  ),
                  _NavTile(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.profileNotificationPrefsButton,
                    onTap: () => context.push(AppRoutes.notificationPreferences),
                  ),
                  _NavTile(
                    icon: Icons.flight_takeoff_rounded,
                    title: l10n.travelModeTitle,
                    subtitle: l10n.travelModeSubtitle,
                    onTap: () async {
                      final picked = await SelectionSheet.show<String>(
                        context: context,
                        title: l10n.travelModeTitle,
                        searchHint: l10n.travelModeTitle,
                        items: const ['İstanbul', 'Ankara', 'İzmir', 'Antalya'],
                        labelBuilder: (s) => s,
                        selectedItem: travelCity,
                      );
                      if (picked != null) {
                        ref.read(travelModeCityProvider.notifier).state = picked;
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SectionHeader(title: l10n.profileSectionCommunities),
                  _NavTile(
                    icon: Icons.groups_rounded,
                    title: l10n.communitiesTitle,
                    onTap: () => context.push(AppRoutes.communities),
                  ),
                  _NavTile(
                    icon: Icons.apartment_rounded,
                    title: l10n.institutionTitle,
                    onTap: () => context.push(AppRoutes.institutions),
                  ),
                  _NavTile(
                    icon: Icons.group_add_outlined,
                    title: l10n.inviteTitle,
                    onTap: () => context.push(AppRoutes.invite),
                  ),
                  _NavTile(
                    icon: Icons.emoji_events_outlined,
                    title: l10n.leaderboardTitle,
                    onTap: () => context.push(AppRoutes.leaderboard),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SectionHeader(title: l10n.profileSectionHelpFaq),
                  _NavTile(
                    icon: Icons.grid_view_rounded,
                    title: l10n.bloodMatrixTitle,
                    onTap: () => context.push(AppRoutes.bloodMatrix),
                  ),
                  _NavTile(
                    icon: Icons.medical_information_outlined,
                    title: l10n.emergencyGuideTitle,
                    onTap: () => context.push(AppRoutes.emergencyGuide),
                  ),
                  _NavTile(
                    icon: Icons.quiz_outlined,
                    title: l10n.faqTitle,
                    onTap: () => context.push(AppRoutes.faq),
                  ),
                  _NavTile(
                    icon: Icons.help_outline_rounded,
                    title: l10n.wizardBloodTypeHowToLearnLink,
                    onTap: () => context.push(AppRoutes.unknownBloodTypeGuide),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SectionHeader(title: l10n.profileSectionAppearance),
                  Text(l10n.profileThemeTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.profileThemeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.profileThemeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.profileThemeDark),
                      ),
                    ],
                    selected: {currentThemeMode},
                    onSelectionChanged: (sel) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(sel.first),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.profileLanguageTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'tr',
                        label: Text(l10n.profileLanguageTr),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text(l10n.profileLanguageEn),
                      ),
                    ],
                    selected: {currentLocale.languageCode},
                    onSelectionChanged: (sel) => ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(sel.first)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionHeader(title: l10n.profileSectionPrivacyData),
                  _NavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicyTitle,
                    onTap: () => context.push(AppRoutes.privacyPolicy),
                  ),
                  _NavTile(
                    icon: Icons.description_outlined,
                    title: l10n.termsOfUseTitle,
                    onTap: () => context.push(AppRoutes.termsOfUse),
                  ),
                  _NavTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.aboutTitle,
                    onTap: () => context.push(AppRoutes.about),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    key: const Key('export_user_data_button'),
                    label: l10n.profileExportDataButton,
                    icon: Icons.download_rounded,
                    onPressed: _onExportData,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    key: const Key('delete_account_button'),
                    label: l10n.profileDeleteAccountButton,
                    icon: Icons.delete_forever_rounded,
                    variant: AppButtonVariant.danger,
                    onPressed: _onConfirmDeleteAccount,
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

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

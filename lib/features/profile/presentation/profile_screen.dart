import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/l10n/locale_provider.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/location_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/theme/theme_mode_provider.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
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
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';

final travelModeCityProvider = StateProvider<String?>((ref) => null);

/// Aşama 7: Profesyonel Bağışçı Kimlik Kartı, gerçek GPS konumu güncelleme,
/// seyahat modu, topluluklar, kurumsal, içerik, iki adımlı hesap silme ve JSON veri indirme ekranı.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isAvailable = true;
  bool _isLocating = false;
  UserPublicProfile? _publicProfile;
  UserSensitiveProfile? _sensitiveProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final repo = ref.read(profileRepositoryProvider);
    final pubRes = await repo.getPublicProfile(uid);
    final senRes = await repo.getSensitiveProfile(uid);
    if (!mounted) return;
    pubRes.when(
      success: (p) {
        if (p != null) {
          setState(() {
            _publicProfile = p;
            _isAvailable = p.isAvailableToDonate;
          });
        }
      },
      failure: (_) {},
    );
    senRes.when(
      success: (s) {
        if (s != null) {
          setState(() => _sensitiveProfile = s);
        }
      },
      failure: (_) {},
    );
  }

  Future<void> _onToggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(profileRepositoryProvider).updateAvailability(
          uid: uid,
          isAvailable: value,
        );
    await _loadProfile();
  }

  Future<void> _onUpdateLocationFromGps() async {
    setState(() => _isLocating = true);
    final loc =
        await ref.read(userLocationProvider.notifier).refreshWithPermission();
    if (!mounted) return;
    setState(() => _isLocating = false);

    if (loc == null) {
      AppSnackbar.show(
        context,
        message: context.l10n.mapNoLocationTitle,
      );
      return;
    }

    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final now = DateTime.now().toUtc();
    final updatedPublic = (_publicProfile ??
            UserPublicProfile(
              uid: uid,
              displayName: 'Ahmet Kaya',
              useNickname: false,
              province: loc.province,
              district: loc.district,
              isAvailableToDonate: _isAvailable,
              updatedAt: now,
            ))
        .copyWith(
      province: loc.province,
      district: loc.district,
      updatedAt: now,
    );

    final currentSensitive = _sensitiveProfile ??
        UserSensitiveProfile(
          fullName: updatedPublic.displayName,
          phoneNumber: '+90 532 ••• •• 48',
          birthDate: DateTime(1993, 4, 18),
          gender: UserGender.male,
          weightKg: 76,
          bloodType: BloodType.aPos,
          updatedAt: now,
        );

    await ref.read(profileRepositoryProvider).saveFullProfile(
          publicProfile: updatedPublic,
          sensitiveProfile: currentSensitive,
        );
    ref.read(profileRevisionProvider.notifier).state++;
    await _loadProfile();
    if (!mounted) return;
    AppSnackbar.show(
      context,
      message: '${loc.formattedArea} (${loc.formattedCoordinates})',
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

  String _initialsFor(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AK';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final travelCity = ref.watch(travelModeCityProvider);
    final gpsState = ref.watch(userLocationProvider);
    ref.listen<int>(profileRevisionProvider, (_, __) => _loadProfile());

    final fullName =
        _sensitiveProfile?.fullName.isNotEmpty == true
            ? _sensitiveProfile!.fullName
            : (_publicProfile?.displayName.isNotEmpty == true
                ? _publicProfile!.displayName
                : 'Ahmet Kaya');
    final bloodType = _sensitiveProfile?.bloodType ?? BloodType.aPos;
    final province = _publicProfile?.province.isNotEmpty == true
        ? _publicProfile!.province
        : 'Ankara';
    final district = _publicProfile?.district.isNotEmpty == true
        ? _publicProfile!.district
        : 'Çankaya';
    final phone = _sensitiveProfile?.phoneNumber ?? '+90 532 ••• •• 48';
    final weightKg = _sensitiveProfile?.weightKg ?? 76;
    final gpsData = gpsState.valueOrNull;

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
                  _DonorIdentityCard(
                    initials: _initialsFor(fullName),
                    fullName: fullName,
                    phone: phone,
                    province: province,
                    district: district,
                    weightKg: weightKg,
                    bloodType: bloodType,
                    isAvailable: _isAvailable,
                    isLocating: _isLocating,
                    gpsCoordinates: gpsData?.formattedCoordinates,
                    verifiedLabel: l10n.profileVerifiedPhone,
                    onUpdateGpsLocation: _onUpdateLocationFromGps,
                    onEditProfile: () async {
                      await context.push(AppRoutes.profileSetup);
                      await _loadProfile();
                    },
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
                    subtitle: '$fullName • ${bloodType.code} • $district / $province',
                    onTap: () async {
                      await context.push(AppRoutes.profileSetup);
                      await _loadProfile();
                    },
                  ),
                  _NavTile(
                    icon: Icons.my_location_rounded,
                    title: l10n.locationPermissionAllowButton,
                    subtitle: gpsData != null
                        ? '$district / $province (${gpsData.formattedCoordinates})'
                        : '$district / $province',
                    onTap: _onUpdateLocationFromGps,
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

/// Profesyonel Dijital Kan Bağışçısı Kimlik Kartı.
class _DonorIdentityCard extends StatelessWidget {
  const _DonorIdentityCard({
    required this.initials,
    required this.fullName,
    required this.phone,
    required this.province,
    required this.district,
    required this.weightKg,
    required this.bloodType,
    required this.isAvailable,
    required this.isLocating,
    required this.verifiedLabel,
    required this.onUpdateGpsLocation,
    required this.onEditProfile,
    this.gpsCoordinates,
  });

  final String initials;
  final String fullName;
  final String phone;
  final String province;
  final String district;
  final int weightKg;
  final BloodType bloodType;
  final bool isAvailable;
  final bool isLocating;
  final String verifiedLabel;
  final String? gpsCoordinates;
  final VoidCallback onUpdateGpsLocation;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
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
                      fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        VerifiedBadge(label: verifiedLabel),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: AppRadius.chipBorder,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$district / $province',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BloodTypeBadge(
                bloodType: bloodType,
                size: BloodBadgeSize.m,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ProfileMetricItem(
                      label: l10n.navDonation,
                      value: '4',
                      icon: Icons.bloodtype_rounded,
                    ),
                  ),
                  const VerticalDivider(width: 16),
                  Expanded(
                    child: _ProfileMetricItem(
                      label: l10n.wizardWeightLabel,
                      value: '$weightKg kg',
                      icon: Icons.monitor_weight_outlined,
                    ),
                  ),
                  const VerticalDivider(width: 16),
                  Expanded(
                    child: _ProfileMetricItem(
                      label: l10n.wizardStep4Title,
                      value: isAvailable ? 'Müsait' : 'Pasif',
                      icon: isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_outline_rounded,
                      valueColor:
                          isAvailable ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('profile_update_gps_location_button'),
                  onPressed: isLocating ? null : onUpdateGpsLocation,
                  icon: isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    l10n.locationPermissionAllowButton,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: FilledButton.tonalIcon(
                  key: const Key('profile_quick_edit_button'),
                  onPressed: onEditProfile,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    l10n.profileEditButton,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetricItem extends StatelessWidget {
  const _ProfileMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: valueColor ?? theme.colorScheme.primary,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
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

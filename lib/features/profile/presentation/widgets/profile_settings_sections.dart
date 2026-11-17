import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/core/widgets/tiles_and_selection_sheet.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

/// Profil ekranı navigasyon ve ayar bölümleri (Bilgilerim, Topluluk, Yardım,
/// Görünüm ve KVKK Veri/Hesap işlemleri).
class ProfileSettingsSections extends StatelessWidget {
  const ProfileSettingsSections({
    required this.fullName,
    required this.bloodType,
    required this.province,
    required this.district,
    required this.currentThemeMode,
    required this.currentLanguageCode,
    required this.onEditProfile,
    required this.onUpdateGpsLocation,
    required this.onTravelCitySelected,
    required this.onThemeModeChanged,
    required this.onLanguageChanged,
    required this.onExportData,
    required this.onDeleteAccount,
    super.key,
    this.gpsCoordinates,
    this.travelCity,
  });

  final String fullName;
  final BloodType bloodType;
  final String province;
  final String district;
  final String? gpsCoordinates;
  final String? travelCity;
  final ThemeMode currentThemeMode;
  final String currentLanguageCode;
  final VoidCallback onEditProfile;
  final VoidCallback onUpdateGpsLocation;
  final ValueChanged<String> onTravelCitySelected;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.profileSectionMyInfo),
        ProfileNavTile(
          icon: Icons.edit_outlined,
          title: l10n.profileEditButton,
          subtitle: '$fullName • ${bloodType.code} • $district / $province',
          onTap: onEditProfile,
        ),
        ProfileNavTile(
          icon: Icons.my_location_rounded,
          title: l10n.locationPermissionAllowButton,
          subtitle: gpsCoordinates != null
              ? '$district / $province ($gpsCoordinates)'
              : '$district / $province',
          onTap: onUpdateGpsLocation,
        ),
        ProfileNavTile(
          icon: Icons.notifications_active_outlined,
          title: l10n.profileNotificationPrefsButton,
          onTap: () => context.push(AppRoutes.notificationPreferences),
        ),
        ProfileNavTile(
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
              onTravelCitySelected(picked);
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionHeader(title: l10n.profileSectionCommunities),
        ProfileNavTile(
          icon: Icons.groups_rounded,
          title: l10n.communitiesTitle,
          onTap: () => context.push(AppRoutes.communities),
        ),
        ProfileNavTile(
          icon: Icons.apartment_rounded,
          title: l10n.institutionTitle,
          onTap: () => context.push(AppRoutes.institutions),
        ),
        ProfileNavTile(
          icon: Icons.group_add_outlined,
          title: l10n.inviteTitle,
          onTap: () => context.push(AppRoutes.invite),
        ),
        ProfileNavTile(
          icon: Icons.emoji_events_outlined,
          title: l10n.leaderboardTitle,
          onTap: () => context.push(AppRoutes.leaderboard),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionHeader(title: l10n.profileSectionHelpFaq),
        ProfileNavTile(
          icon: Icons.grid_view_rounded,
          title: l10n.bloodMatrixTitle,
          onTap: () => context.push(AppRoutes.bloodMatrix),
        ),
        ProfileNavTile(
          icon: Icons.medical_information_outlined,
          title: l10n.emergencyGuideTitle,
          onTap: () => context.push(AppRoutes.emergencyGuide),
        ),
        ProfileNavTile(
          icon: Icons.quiz_outlined,
          title: l10n.faqTitle,
          onTap: () => context.push(AppRoutes.faq),
        ),
        ProfileNavTile(
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
          onSelectionChanged: (sel) => onThemeModeChanged(sel.first),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.profileLanguageTitle, style: theme.textTheme.titleSmall),
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
          selected: {currentLanguageCode},
          onSelectionChanged: (sel) => onLanguageChanged(sel.first),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: l10n.profileSectionPrivacyData),
        ProfileNavTile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacyPolicyTitle,
          onTap: () => context.push(AppRoutes.privacyPolicy),
        ),
        ProfileNavTile(
          icon: Icons.description_outlined,
          title: l10n.termsOfUseTitle,
          onTap: () => context.push(AppRoutes.termsOfUse),
        ),
        ProfileNavTile(
          icon: Icons.info_outline_rounded,
          title: l10n.aboutTitle,
          onTap: () => context.push(AppRoutes.about),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          key: const Key('export_user_data_button'),
          label: l10n.profileExportDataButton,
          icon: Icons.download_rounded,
          onPressed: onExportData,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          key: const Key('delete_account_button'),
          label: l10n.profileDeleteAccountButton,
          icon: Icons.delete_forever_rounded,
          variant: AppButtonVariant.danger,
          onPressed: onDeleteAccount,
        ),
      ],
    );
  }
}

class ProfileNavTile extends StatelessWidget {
  const ProfileNavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
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

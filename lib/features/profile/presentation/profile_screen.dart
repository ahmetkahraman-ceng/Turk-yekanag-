import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/l10n/locale_provider.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/location_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/theme/theme_mode_provider.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/auth/data/firebase_auth_repository.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donor_status_snapshot.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/widgets/donor_identity_card.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/widgets/profile_settings_sections.dart';

final travelModeCityProvider = StateProvider<String?>((ref) => null);

/// Aşama 7: Profesyonel Bağışçı Kimlik Kartı, gerçek GPS konumu güncelleme,
/// seyahat modu, topluluklar, kurumsal, içerik, iki adımlı hesap silme ve JSON veri indirme ekranı.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLocating = false;

  Future<void> _onToggleAvailability(bool value) async {
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(profileRepositoryProvider).updateAvailability(
          uid: uid,
          isAvailable: value,
        );
    ref.read(profileRevisionProvider.notifier).state++;
  }

  Future<void> _onUpdateLocationFromGps(DonorStatusSnapshot? snapshot) async {
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
    final updatedPublic = (snapshot?.publicProfile ??
            UserPublicProfile(
              uid: uid,
              displayName: snapshot?.displayName ?? 'Ahmet Kaya',
              useNickname: false,
              province: loc.province,
              district: loc.district,
              isAvailableToDonate: snapshot?.isAvailableToDonate ?? true,
              updatedAt: now,
            ))
        .copyWith(
      province: loc.province,
      district: loc.district,
      updatedAt: now,
    );

    final currentSensitive = snapshot?.sensitiveProfile ??
        UserSensitiveProfile(
          fullName: updatedPublic.displayName,
          phoneNumber: snapshot?.phoneNumber ?? '+90 532 ••• •• 48',
          birthDate: DateTime(1993, 4, 18),
          gender: snapshot?.gender ?? UserGender.male,
          weightKg: snapshot?.weightKg ?? 76,
          bloodType: snapshot?.bloodType ?? BloodType.aPos,
          updatedAt: now,
        );

    await ref.read(profileRepositoryProvider).saveFullProfile(
          publicProfile: updatedPublic,
          sensitiveProfile: currentSensitive,
        );
    ref.read(profileRevisionProvider.notifier).state++;
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
    final donorStatus = ref.watch(currentDonorStatusProvider).valueOrNull;

    final fullName = donorStatus?.fullName ?? 'Ahmet Kaya';
    final bloodType = donorStatus?.bloodType ?? BloodType.aPos;
    final province = donorStatus?.province ?? 'Ankara';
    final district = donorStatus?.district ?? 'Çankaya';
    final phone = donorStatus?.phoneNumber ?? '+90 532 ••• •• 48';
    final weightKg = donorStatus?.weightKg ?? 76;
    final donationCount = donorStatus?.totalDonations ?? 3;
    final remainingDays = donorStatus?.remainingDays ?? 24;
    final isEligibleNow = donorStatus?.isEligibleNow ?? false;
    final isAvailable = donorStatus?.isAvailableToDonate ?? true;
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
                  DonorIdentityCard(
                    initials: _initialsFor(fullName),
                    fullName: fullName,
                    phone: phone,
                    province: province,
                    district: district,
                    weightKg: weightKg,
                    donationCount: donationCount,
                    remainingDays: remainingDays,
                    isEligibleNow: isEligibleNow,
                    bloodType: bloodType,
                    isAvailable: isAvailable,
                    isLocating: _isLocating,
                    gpsCoordinates: gpsData?.formattedCoordinates,
                    verifiedLabel: l10n.profileVerifiedPhone,
                    onUpdateGpsLocation: () =>
                        _onUpdateLocationFromGps(donorStatus),
                    onEditProfile: () => context.push(AppRoutes.profileSetup),
                    onOpenDonationTab: () => context.go(AppRoutes.donation),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: SwitchListTile(
                      key: const Key('available_to_donate_switch'),
                      value: isAvailable,
                      onChanged: _onToggleAvailability,
                      title: Text(
                        l10n.profileAvailableSwitchTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        remainingDays > 0
                            ? '${l10n.donorStatusWaitingCard(remainingDays)} • ${l10n.profileAvailableSwitchSubtitle}'
                            : l10n.profileAvailableSwitchSubtitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProfileSettingsSections(
                    fullName: fullName,
                    bloodType: bloodType,
                    province: province,
                    district: district,
                    gpsCoordinates: gpsData?.formattedCoordinates,
                    travelCity: travelCity,
                    currentThemeMode: currentThemeMode,
                    currentLanguageCode: currentLocale.languageCode,
                    onEditProfile: () => context.push(AppRoutes.profileSetup),
                    onUpdateGpsLocation: () =>
                        _onUpdateLocationFromGps(donorStatus),
                    onTravelCitySelected: (city) =>
                        ref.read(travelModeCityProvider.notifier).state = city,
                    onThemeModeChanged: (mode) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(mode),
                    onLanguageChanged: (lang) => ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(lang)),
                    onExportData: _onExportData,
                    onDeleteAccount: _onConfirmDeleteAccount,
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

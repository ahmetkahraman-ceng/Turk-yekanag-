import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/l10n/locale_provider.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/theme/theme_mode_provider.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/auth/data/firebase_auth_repository.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';

/// Profil ve KVKK ayarları ekranı:
/// - "Bağışa uygunum" anahtarı
/// - Profil düzenleme ve fotoğraf yükleme (Storage)
/// - Tema (Aydınlık/Karanlık/Sistem) ve Dil (TR/EN) seçimi
/// - Bildirim tercihleri, Gizlilik Politikası & Kullanım Şartları
/// - "Verilerimi İndir (JSON)" ve "Hesabımı Sil (Cloud Function)"
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isAvailable = true;
  String? _photoUrl;

  Future<void> _onToggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(profileRepositoryProvider).updateAvailability(
          uid: uid,
          isAvailable: value,
        );
  }

  Future<void> _onUploadPhoto() async {
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final result = await ref.read(profileRepositoryProvider).uploadProfilePhoto(
          uid: uid,
          bytes: Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0xD9]),
        );
    if (!mounted) return;
    result.when(
      success: (url) => setState(() => _photoUrl = url),
      failure: (_) {},
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileDeleteConfirmTitle),
        content: Text(l10n.profileDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.profileDeleteConfirmAction),
          ),
        ],
      ),
    );

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    _photoUrl != null
                        ? Icons.check_circle_rounded
                        : Icons.person_rounded,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                TextButton.icon(
                  onPressed: _onUploadPhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l10n.profilePhotoChangeButton),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.profileEditButton),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.profileSetup),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.profileNotificationPrefsButton),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.notificationPreferences),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: Text(l10n.wizardBloodTypeHowToLearnLink),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.unknownBloodTypeGuide),
          ),
          const Divider(),
          Text(l10n.profileThemeTitle, style: theme.textTheme.titleMedium),
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
            onSelectionChanged: (sel) =>
                ref.read(themeModeProvider.notifier).setThemeMode(sel.first),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.profileLanguageTitle, style: theme.textTheme.titleMedium),
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
            onSelectionChanged: (sel) =>
                ref.read(localeProvider.notifier).setLocale(Locale(sel.first)),
          ),
          const Divider(height: AppSpacing.xl),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicyTitle),
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfUseTitle),
            onTap: () => context.push(AppRoutes.termsOfUse),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            key: const Key('export_user_data_button'),
            label: l10n.profileExportDataButton,
            icon: Icons.download_rounded,
            onPressed: _onExportData,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const Key('delete_account_button'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              minimumSize: const Size(
                double.infinity,
                AppSpacing.minTouchTarget,
              ),
            ),
            onPressed: _onConfirmDeleteAccount,
            icon: const Icon(Icons.delete_forever_rounded),
            label: Text(l10n.profileDeleteAccountButton),
          ),
        ],
      ),
    );
  }
}

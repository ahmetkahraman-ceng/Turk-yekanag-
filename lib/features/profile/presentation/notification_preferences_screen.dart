import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/notification_preferences.dart';

/// Bildirim tercihleri ekranı (Aciliyet seviyesi, 5/10/25/50 km yarıçap, sessiz saatler ve kritik izin).
class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  NotificationPreferences _prefs = const NotificationPreferences();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final result = await ref
        .read(profileRepositoryProvider)
        .getNotificationPreferences(uid);
    if (!mounted) return;
    result.when(
      success: (loaded) => setState(() => _prefs = loaded),
      failure: (_) {},
    );
  }

  Future<void> _savePreferences() async {
    final l10n = context.l10n;
    setState(() => _isSaving = true);
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    await ref.read(profileRepositoryProvider).saveNotificationPreferences(
          uid: uid,
          preferences: _prefs,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.notifPrefsSavedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifPrefsTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(l10n.notifUrgencyTitle, style: theme.textTheme.titleMedium),
                RadioGroup<NotificationUrgencyFilter>(
                  groupValue: _prefs.minUrgency,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _prefs = _prefs.copyWith(minUrgency: val));
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile<NotificationUrgencyFilter>(
                        value: NotificationUrgencyFilter.all,
                        title: Text(l10n.notifUrgencyAll),
                      ),
                      RadioListTile<NotificationUrgencyFilter>(
                        value: NotificationUrgencyFilter.urgentOnly,
                        title: Text(l10n.notifUrgencyUrgentOnly),
                      ),
                      RadioListTile<NotificationUrgencyFilter>(
                        value: NotificationUrgencyFilter.criticalOnly,
                        title: Text(l10n.notifUrgencyCriticalOnly),
                      ),
                    ],
                  ),
                ),
                const Divider(height: AppSpacing.xl),
                Text(l10n.notifRadiusTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final km in NotificationPreferences.supportedRadiiKm)
                      ChoiceChip(
                        key: Key('radius_chip_$km'),
                        label: Text(l10n.notifRadiusKm(km)),
                        selected: _prefs.radiusKm == km,
                        onSelected: (_) {
                          setState(() => _prefs = _prefs.copyWith(radiusKm: km));
                        },
                      ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                Text(
                  l10n.notifQuietHoursTitle,
                  style: theme.textTheme.titleMedium,
                ),
                SwitchListTile(
                  key: const Key('quiet_hours_enable_switch'),
                  value: _prefs.quietHoursEnabled,
                  onChanged: (val) {
                    setState(
                      () => _prefs = _prefs.copyWith(quietHoursEnabled: val),
                    );
                  },
                  title: Text(l10n.notifQuietHoursEnable),
                ),
                SwitchListTile(
                  key: const Key('quiet_hours_allow_critical_switch'),
                  value: _prefs.allowCriticalInQuietHours,
                  onChanged: _prefs.quietHoursEnabled
                      ? (val) {
                          setState(
                            () => _prefs = _prefs.copyWith(
                              allowCriticalInQuietHours: val,
                            ),
                          );
                        }
                      : null,
                  title: Text(l10n.notifQuietHoursAllowCritical),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: l10n.commonSave,
                  isLoading: _isSaving,
                  onPressed: _savePreferences,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

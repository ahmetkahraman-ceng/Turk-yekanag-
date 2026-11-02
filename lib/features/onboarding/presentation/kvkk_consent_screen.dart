import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';

/// KVKK Aydınlatma Metni ve 3 ayrı açık rıza kutusu (Sağlık Verisi, Konum, Bildirim) ekranı.
class KvkkConsentScreen extends ConsumerStatefulWidget {
  const KvkkConsentScreen({super.key});

  @override
  ConsumerState<KvkkConsentScreen> createState() => _KvkkConsentScreenState();
}

class _KvkkConsentScreenState extends ConsumerState<KvkkConsentScreen> {
  bool _healthConsent = false;
  bool _locationConsent = false;
  bool _notificationConsent = false;

  bool get _allApproved =>
      _healthConsent && _locationConsent && _notificationConsent;

  void _onApproveAndContinue() {
    if (!_allApproved) return;
    ref.read(kvkkConsentProvider.notifier).approveAll();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kvkkScreenTitle),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.kvkkLightingTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.kvkkLightingBody,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  context.push(AppRoutes.privacyPolicy),
                              icon: const Icon(Icons.privacy_tip_outlined),
                              label: Text(l10n.kvkkReadPrivacyPolicy),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  context.push(AppRoutes.termsOfUse),
                              icon: const Icon(Icons.description_outlined),
                              label: Text(l10n.kvkkReadTermsOfUse),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  key: const Key('consent_health_checkbox'),
                  value: _healthConsent,
                  onChanged: (val) =>
                      setState(() => _healthConsent = val ?? false),
                  title: Text(
                    l10n.kvkkConsentHealthTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(l10n.kvkkConsentHealthSubtitle),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Divider(),
                CheckboxListTile(
                  key: const Key('consent_location_checkbox'),
                  value: _locationConsent,
                  onChanged: (val) =>
                      setState(() => _locationConsent = val ?? false),
                  title: Text(
                    l10n.kvkkConsentLocationTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(l10n.kvkkConsentLocationSubtitle),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Divider(),
                CheckboxListTile(
                  key: const Key('consent_notification_checkbox'),
                  value: _notificationConsent,
                  onChanged: (val) =>
                      setState(() => _notificationConsent = val ?? false),
                  title: Text(
                    l10n.kvkkConsentNotificationTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(l10n.kvkkConsentNotificationSubtitle),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (!_allApproved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      l10n.kvkkAllConsentsRequiredWarning,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                PrimaryButton(
                  label: l10n.kvkkApproveAndContinue,
                  onPressed: _allApproved ? _onApproveAndContinue : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

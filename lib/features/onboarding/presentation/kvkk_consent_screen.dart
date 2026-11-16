import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';

/// KVKK ekranı:
/// Kısa özet kartı + Aydınlatma metni ve Açık rıza detay sayfaları,
/// ayrı onay kutuları (sağlık verisi [Zorunlu], konum [Zorunlu], bildirim [Opsiyonel]),
/// zorunlular seçilmeden Devam pasif.
class KvkkConsentScreen extends ConsumerStatefulWidget {
  const KvkkConsentScreen({super.key});

  @override
  ConsumerState<KvkkConsentScreen> createState() => _KvkkConsentScreenState();
}

class _KvkkConsentScreenState extends ConsumerState<KvkkConsentScreen> {
  bool _healthConsent = false;
  bool _locationConsent = false;
  bool _notificationConsent = false;

  bool get _mandatoryApproved => _healthConsent && _locationConsent;

  void _onApproveAndContinue() {
    if (!_mandatoryApproved) return;
    ref.read(kvkkConsentProvider.notifier).approveConsents(
          healthDataConsent: _healthConsent,
          locationConsent: _locationConsent,
          notificationConsent: _notificationConsent,
        );
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.kvkkScreenTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                l10n.kvkkSummaryCardTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
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
                              label: Text(l10n.kvkkIlluminationLink),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  context.push(AppRoutes.termsOfUse),
                              icon: const Icon(Icons.description_outlined),
                              label: Text(l10n.kvkkExplicitConsentLink),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ConsentCheckboxCard(
                    checkboxKey: const Key('consent_health_checkbox'),
                    value: _healthConsent,
                    onChanged: (v) => setState(() => _healthConsent = v),
                    title: l10n.kvkkConsentHealthTitle,
                    subtitle: l10n.kvkkConsentHealthSubtitle,
                    badgeText: l10n.kvkkRequiredBadge,
                    isRequired: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ConsentCheckboxCard(
                    checkboxKey: const Key('consent_location_checkbox'),
                    value: _locationConsent,
                    onChanged: (v) => setState(() => _locationConsent = v),
                    title: l10n.kvkkConsentLocationTitle,
                    subtitle: l10n.kvkkConsentLocationSubtitle,
                    badgeText: l10n.kvkkRequiredBadge,
                    isRequired: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ConsentCheckboxCard(
                    checkboxKey: const Key('consent_notification_checkbox'),
                    value: _notificationConsent,
                    onChanged: (v) => setState(() => _notificationConsent = v),
                    title: l10n.kvkkConsentNotificationTitle,
                    subtitle: l10n.kvkkConsentNotificationSubtitle,
                    badgeText: l10n.kvkkOptionalBadge,
                    isRequired: false,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: ResponsiveConstrainedBox(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_mandatoryApproved)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        l10n.kvkkAllConsentsRequiredWarning,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  AppButton(
                    key: const Key('kvkk_continue_button'),
                    label: l10n.kvkkContinueButton,
                    enableHaptic: true,
                    onPressed:
                        _mandatoryApproved ? _onApproveAndContinue : null,
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

class _ConsentCheckboxCard extends StatelessWidget {
  const _ConsentCheckboxCard({
    required this.checkboxKey,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.isRequired,
  });

  final Key checkboxKey;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;
  final String badgeText;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: CheckboxListTile(
        key: checkboxKey,
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Expanded(
              child: Text(title, style: theme.textTheme.titleSmall),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isRequired
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.chipBorder,
              ),
              child: Text(
                badgeText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isRequired
                      ? theme.colorScheme.onPrimaryContainer
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxs),
          child: Text(subtitle, style: theme.textTheme.bodySmall),
        ),
      ),
    );
  }
}

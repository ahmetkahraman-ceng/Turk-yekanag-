import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';

/// "Kan grubumu bilmiyorum" seçildiğinde kan grubunun nasıl öğrenileceğini anlatan rehber ekranı.
class UnknownBloodTypeInfoScreen extends StatelessWidget {
  const UnknownBloodTypeInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final steps = <({IconData icon, String title, String body})>[
      (
        icon: Icons.bloodtype_rounded,
        title: l10n.unknownBloodGuideStep1Title,
        body: l10n.unknownBloodGuideStep1Body,
      ),
      (
        icon: Icons.local_hospital_outlined,
        title: l10n.unknownBloodGuideStep2Title,
        body: l10n.unknownBloodGuideStep2Body,
      ),
      (
        icon: Icons.assignment_outlined,
        title: l10n.unknownBloodGuideStep3Title,
        body: l10n.unknownBloodGuideStep3Body,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.unknownBloodGuideTitle),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  l10n.unknownBloodGuideIntro,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final step in steps) ...[
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            step.icon,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  step.body,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/features/matching/domain/blood_compatibility_engine.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Aşama 7.6: Kan grupları uyumluluk matrisi (dokununca "kime verebilir/kimden alabilir" vurgusu).
class BloodCompatibilityMatrixScreen extends StatefulWidget {
  const BloodCompatibilityMatrixScreen({super.key});

  @override
  State<BloodCompatibilityMatrixScreen> createState() =>
      _BloodCompatibilityMatrixScreenState();
}

class _BloodCompatibilityMatrixScreenState
    extends State<BloodCompatibilityMatrixScreen> {
  BloodType _selected = BloodType.aPos;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final canDonateTo = BloodType.knownValues
        .where(
          (recipient) => BloodCompatibilityEngine.isCompatible(
            donor: _selected,
            recipient: recipient,
            productType: BloodProductType.erythrocyte,
          ),
        )
        .toList();

    final canReceiveFrom = BloodCompatibilityEngine.compatibleDonorTypesFor(
      recipient: _selected,
      productType: BloodProductType.erythrocyte,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bloodMatrixTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final type in BloodType.knownValues)
                        GestureDetector(
                          key: Key('matrix_select_${type.code}'),
                          onTap: () => setState(() => _selected = type),
                          child: BloodTypeBadge(
                            bloodType: type,
                            size: BloodBadgeSize.m,
                            isSelected: _selected == type,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l10n.bloodMatrixCanGiveTo),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final t in canDonateTo)
                              Chip(
                                avatar: const Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                label: Text(
                                  t.code,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l10n.bloodMatrixCanReceiveFrom),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final t in canReceiveFrom)
                              Chip(
                                avatar: const Icon(
                                  Icons.south_west_rounded,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                label: Text(
                                  t.code,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
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

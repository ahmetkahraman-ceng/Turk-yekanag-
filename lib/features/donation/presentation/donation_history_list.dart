import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donation_record.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Bağış geçmişi listesi bileşeni (boş durumda [EmptyState] gösterir).
class DonationHistoryList extends StatelessWidget {
  const DonationHistoryList({
    required this.records,
    required this.onDeleteManual,
    super.key,
  });

  final List<DonationRecord> records;
  final ValueChanged<String> onDeleteManual;

  String _productLabel(BuildContext context, BloodProductType type) {
    final l10n = context.l10n;
    return switch (type) {
      BloodProductType.wholeBlood => l10n.productWholeBlood,
      BloodProductType.erythrocyte => l10n.productErythrocyte,
      BloodProductType.platelet => l10n.productPlatelet,
      BloodProductType.plasma => l10n.productPlasma,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).languageCode;

    if (records.isEmpty) {
      return EmptyState(
        title: l10n.donationEmptyTitle,
        subtitle: l10n.donationEmptySubtitle,
        icon: Icons.favorite_border_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.donationHistorySectionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final item in records)
          Card(
            key: Key('donation_record_card_${item.id}'),
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  item.source == DonationRecordSource.request
                      ? Icons.verified_rounded
                      : Icons.volunteer_activism_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                '${item.place} • ${_productLabel(context, item.productType)}',
              ),
              subtitle: Text(
                '${DateFormat.yMMMd(localeName).format(item.donatedAt.toLocal())} — '
                '${item.source == DonationRecordSource.request ? l10n.donationSourceRequestBadge : l10n.donationSourceManualBadge}',
              ),
              trailing: item.source == DonationRecordSource.manual
                  ? Semantics(
                      button: true,
                      label: l10n.donationDeleteManualTooltip,
                      child: IconButton(
                        key: Key('delete_donation_${item.id}'),
                        tooltip: l10n.donationDeleteManualTooltip,
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => onDeleteManual(item.id),
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';

/// Talep sahibine özel yönetim kartı:
/// Düzenleme, Karşılandı işaretleme, Süre uzatma (+24s), İptal ve "Yeterli kişi geldi" anahtarı.
class RequestOwnerActionsCard extends ConsumerWidget {
  const RequestOwnerActionsCard({
    required this.request,
    required this.onUpdated,
    super.key,
  });

  final BloodRequest request;
  final ValueChanged<BloodRequest> onUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final repo = ref.read(bloodRequestRepositoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.requestOwnerActionsTitle,
              style: theme.textTheme.titleMedium,
            ),
            SwitchListTile(
              key: const Key('stop_new_offers_switch'),
              contentPadding: EdgeInsets.zero,
              value: request.stopNewOffers,
              title: Text(l10n.requestStopNewOffersSwitch),
              onChanged: (val) async {
                final res = await repo.toggleStopNewOffers(
                  requestId: request.id,
                  stopNewOffers: val,
                );
                res.when(success: onUpdated, failure: (_) {});
              },
            ),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                OutlinedButton(
                  onPressed: () => context.push(
                    '${AppRoutes.requests}/create',
                    extra: request,
                  ),
                  child: Text(l10n.requestEditTitle),
                ),
                ElevatedButton(
                  key: const Key('mark_fulfilled_button'),
                  onPressed: () async {
                    final res = await repo.updateStatus(
                      requestId: request.id,
                      status: RequestStatus.fulfilled,
                    );
                    res.when(success: onUpdated, failure: (_) {});
                  },
                  child: Text(l10n.requestMarkFulfilledButton),
                ),
                OutlinedButton(
                  key: const Key('extend_expiry_button'),
                  onPressed: () async {
                    final res = await repo.extendExpiry(requestId: request.id);
                    res.when(success: onUpdated, failure: (_) {});
                  },
                  child: Text(l10n.requestExtendExpiryButton),
                ),
                TextButton(
                  key: const Key('cancel_request_button'),
                  onPressed: () async {
                    final res = await repo.updateStatus(
                      requestId: request.id,
                      status: RequestStatus.cancelled,
                    );
                    res.when(success: onUpdated, failure: (_) {});
                  },
                  child: Text(l10n.requestCancelButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

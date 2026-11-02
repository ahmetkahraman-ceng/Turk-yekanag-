import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/matching/presentation/donor_offer_panel.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/request_owner_actions_card.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/share_request_card_dialog.dart';

/// Talep detay ekranı: Tüm talep bilgileri, yardım teklif sayacı, paylaşım kartı,
/// raporlama, talep sahibi yönetim araçları ve bağışçı eşleşme paneli.
class RequestDetailScreen extends ConsumerStatefulWidget {
  const RequestDetailScreen({
    required this.requestId,
    this.donorBloodType = BloodType.aPos,
    super.key,
  });

  final String requestId;
  final BloodType donorBloodType;

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  BloodRequest? _request;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    final res = await ref
        .read(bloodRequestRepositoryProvider)
        .getRequestById(widget.requestId);
    if (!mounted) return;
    res.when(
      success: (req) => setState(() {
        _request = req;
        _isLoading = false;
      }),
      failure: (_) => setState(() => _isLoading = false),
    );
  }

  String _productLabel(BuildContext context, BloodProductType type) {
    final l10n = context.l10n;
    return switch (type) {
      BloodProductType.wholeBlood => l10n.productWholeBlood,
      BloodProductType.erythrocyte => l10n.productErythrocyte,
      BloodProductType.platelet => l10n.productPlatelet,
      BloodProductType.plasma => l10n.productPlasma,
    };
  }

  String _urgencyLabel(BuildContext context, RequestUrgency urgency) {
    final l10n = context.l10n;
    return switch (urgency) {
      RequestUrgency.critical => l10n.urgencyCritical,
      RequestUrgency.today => l10n.urgencyToday,
      RequestUrgency.thisWeek => l10n.urgencyThisWeek,
    };
  }

  Future<void> _showReportDialog(BloodRequest req) async {
    final l10n = context.l10n;
    final reasonController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.requestReportDialogTitle),
        content: TextField(
          key: const Key('report_reason_field'),
          controller: reasonController,
          decoration: InputDecoration(hintText: l10n.requestReportReasonHint),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            key: const Key('submit_report_button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (submitted == true) {
      final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
      await ref.read(bloodRequestRepositoryProvider).reportRequest(
            requestId: req.id,
            reporterUid: uid,
            reason: reasonController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requestReportSubmittedMessage)),
      );
    }
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final req = _request;
    final currentUid = ref.watch(currentUserIdStateProvider) ?? 'local-user';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.requestDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (req == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.requestDetailTitle)),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.notFoundTitle,
          subtitle: l10n.notFoundMessage,
        ),
      );
    }

    final isOwner = req.requesterUid == currentUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requestDetailTitle),
        actions: [
          IconButton(
            key: const Key('share_request_button'),
            tooltip: l10n.requestShareButton,
            onPressed: () => ShareRequestCardDialog.show(context, req),
            icon: const Icon(Icons.share_rounded),
          ),
          IconButton(
            key: const Key('report_request_button'),
            tooltip: l10n.requestReportButton,
            onPressed: () => _showReportDialog(req),
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              child: Text(
                                req.bloodType.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(_urgencyLabel(context, req.urgency)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '${req.patientInitials} • ${_productLabel(context, req.productType)} (${l10n.requestUnitsValue(req.unitsNeeded)})',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${req.hospital.name} — ${req.department}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          '${req.hospital.district} / ${req.hospital.province}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (req.notes.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(req.notes),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Chip(
                          avatar: const Icon(Icons.people_alt_outlined, size: 18),
                          label: Text(l10n.requestOfferCountBadge(req.offerCount)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DonorOfferPanel(
                  request: req,
                  donorBloodType: widget.donorBloodType,
                  onOffersChanged: () {
                    setState(() {
                      _request = req.copyWith(offerCount: req.offerCount + 1);
                    });
                  },
                ),
                if (isOwner) ...[
                  const SizedBox(height: AppSpacing.md),
                  RequestOwnerActionsCard(
                    request: req,
                    onUpdated: (u) => setState(() => _request = u),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_shadows.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/skeleton_widgets.dart';
import 'package:turkiye_kan_agi/core/widgets/status_and_urgency_tags.dart';
import 'package:turkiye_kan_agi/features/matching/presentation/donor_offer_panel.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/request_owner_actions_card.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/share_request_card_dialog.dart';

/// Talep detay ekranı:
/// - Üstte büyük BloodTypeBadge (Hero) + UrgencyTag + StatusTag
/// - Bilgi kartları (hastane+servis+yol tarifi, ürün tipi ve ünite, oluşturulma ve kalan süre çubuğu)
/// - "Kaç kişi yardım teklif etti", güven bölümü
/// - Alt sabit çubukta büyük "Yardım Edebilirim", yanında paylaş ve "⋯" menüsü (rapor et)
/// - Talep sahibi görünümü: gelen teklifler + Karşılandı/Süreyi uzat/Düzenle/İptal
/// - Karşılandı/İptal/Süresi doldu ise buton pasif ve açıklayıcı bant.
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
      AppSnackbar.show(context, message: l10n.requestReportSubmittedMessage);
    }
    reasonController.dispose();
  }

  Future<void> _onPrimaryCanHelp(BloodRequest req) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmSheet.show(
      context: context,
      icon: Icons.favorite_rounded,
      title: l10n.canHelpConfirmTitle,
      message: '${l10n.canHelpConfirmBody}\n\n${l10n.canHelpEligibilityReminder}',
      confirmLabel: l10n.actionCanHelp,
    );
    if (!confirmed || !mounted) return;
    context.push(AppRoutes.donorTracking, extra: req);
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
        body: const SkeletonList(itemCount: 3),
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
    final isOpen = req.status == RequestStatus.open && !req.stopNewOffers;

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
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: AppShadows.bottomBarFor(theme.brightness),
          ),
          child: ResponsiveConstrainedBox(
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    key: const Key('bottom_can_help_button'),
                    label: l10n.actionCanHelp,
                    icon: Icons.volunteer_activism_rounded,
                    enableHaptic: true,
                    onPressed: isOpen ? () => _onPrimaryCanHelp(req) : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton.outlined(
                  tooltip: l10n.requestShareButton,
                  onPressed: () => ShareRequestCardDialog.show(context, req),
                  icon: const Icon(Icons.share_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          if (req.status != RequestStatus.open)
            _ClosedStatusBanner(status: req.status),
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
                            Hero(
                              tag: 'blood_badge_${req.id}',
                              child: BloodTypeBadge(
                                bloodType: req.bloodType,
                                size: BloodBadgeSize.l,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: AppSpacing.xs,
                                    runSpacing: AppSpacing.xxs,
                                    children: [
                                      UrgencyTag(urgency: req.urgency),
                                      StatusTag(status: req.status),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${req.patientInitials} • ${_productLabel(context, req.productType)} (${l10n.requestUnitsValue(req.unitsNeeded)})',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '${req.hospital.name} — ${req.department}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${req.hospital.district} / ${req.hospital.province}',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (req.notes.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(req.notes),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        const LinearProgressIndicator(value: 0.65),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.people_alt_outlined,
                                size: 18,
                              ),
                              label: Text(
                                l10n.requestOfferCountBadge(req.offerCount),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.go(AppRoutes.map),
                              icon: const Icon(Icons.directions_rounded),
                              label: Text(l10n.requestDirectionsButton),
                            ),
                          ],
                        ),
                      ],
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
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.requestTrustSectionTitle,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const VerifiedBadge(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.requestTrustSectionBody,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
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
          ),
        ],
      ),
    );
  }
}

class _ClosedStatusBanner extends StatelessWidget {
  const _ClosedStatusBanner({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = switch (status) {
      RequestStatus.fulfilled => l10n.requestClosedBannerFulfilled,
      RequestStatus.cancelled => l10n.requestClosedBannerCancelled,
      RequestStatus.expired => l10n.requestClosedBannerExpired,
      RequestStatus.open => '',
    };
    return Container(
      width: double.infinity,
      color: AppColors.warningLight,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

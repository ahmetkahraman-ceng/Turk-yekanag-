import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// WhatsApp, Instagram ve X için otomatik oluşturulan görsel paylaşım kartı
/// ve hazır paylaşım metni / deep link diyalogu.
class ShareRequestCardDialog extends StatelessWidget {
  const ShareRequestCardDialog({
    required this.request,
    super.key,
  });

  final BloodRequest request;

  static Future<void> show(BuildContext context, BloodRequest request) {
    return showDialog<void>(
      context: context,
      builder: (_) => ShareRequestCardDialog(request: request),
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

  String buildShareText(BuildContext context) {
    final product = _productLabel(context, request.productType);
    final urgency = _urgencyLabel(context, request.urgency);
    return '🩸 ACİL KAN ÇAĞRISI ($urgency)\n'
        'Kan Grubu: ${request.bloodType.code} ($product - ${request.unitsNeeded} Ünite)\n'
        'Hastane: ${request.hospital.name} (${request.hospital.district}/${request.hospital.province})\n'
        'Hasta: ${request.patientInitials}\n'
        'Detay ve Yardım İçin: ${request.deepLinkUrl}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final shareText = buildShareText(context);

    return AlertDialog(
      title: Text(l10n.requestShareCardTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: const Key('share_visual_card_boundary'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primaryContainerDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Text(
                            request.bloodType.code,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            _urgencyLabel(context, request.urgency),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${_productLabel(context, request.productType)} • ${l10n.requestUnitsValue(request.unitsNeeded)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      request.hospital.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${request.hospital.district} / ${request.hospital.province}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      request.deepLinkUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SelectableText(
              shareText,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
        PrimaryButton(
          key: const Key('copy_share_text_button'),
          isExpanded: false,
          icon: Icons.copy_rounded,
          label: l10n.requestShareCopyTextButton,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: shareText));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.requestShareCopiedMessage)),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

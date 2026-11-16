import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:turkiye_kan_agi/core/branding/blood_logo.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Paylaşım kartı:
/// RepaintBoundary + toImage ile PNG üretir; marka renkli, kan grubu büyük,
/// hastane, aciliyet, uygulama adı ve link; "WhatsApp'ta paylaş / Görsel olarak paylaş".
class ShareRequestCardDialog extends StatefulWidget {
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

  @override
  State<ShareRequestCardDialog> createState() => _ShareRequestCardDialogState();
}

class _ShareRequestCardDialogState extends State<ShareRequestCardDialog> {
  final GlobalKey _boundaryKey = GlobalKey();

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
      RequestUrgency.critical => l10n.urgencyCriticalShort,
      RequestUrgency.today => l10n.urgencyTodayShort,
      RequestUrgency.thisWeek => l10n.urgencyThisWeekShort,
    };
  }

  String buildShareText(BuildContext context) {
    final req = widget.request;
    final product = _productLabel(context, req.productType);
    final urgency = _urgencyLabel(context, req.urgency);
    return '🩸 ACİL KAN ÇAĞRISI ($urgency)\n'
        'Kan Grubu: ${req.bloodType.code} ($product - ${req.unitsNeeded} Ünite)\n'
        'Hastane: ${req.hospital.name} (${req.hospital.district}/${req.hospital.province})\n'
        'Hasta: ${req.patientInitials}\n'
        'Detay ve Yardım İçin: ${req.deepLinkUrl}';
  }

  Future<Uint8List?> capturePngBytes() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _copyAndNotify(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppSnackbar.show(context, message: context.l10n.requestShareCopiedMessage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final req = widget.request;
    final shareText = buildShareText(context);

    return AlertDialog(
      title: Text(l10n.requestShareCardTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: const Key('share_visual_card_boundary'),
              child: RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.cardBorder,
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
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.button),
                            ),
                            child: Text(
                              req.bloodType.code,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.2),
                              borderRadius: AppRadius.chipBorder,
                            ),
                            child: Text(
                              _urgencyLabel(context, req.urgency),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '${_productLabel(context, req.productType)} • ${l10n.requestUnitsValue(req.unitsNeeded)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        req.hospital.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      Text(
                        '${req.hospital.district} / ${req.hospital.province}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const BloodLogo(size: 24, monochrome: true),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              '${l10n.appTitle} • ${req.deepLinkUrl}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SelectableText(shareText, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.shareWhatsAppButton,
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () => _copyAndNotify(shareText),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l10n.shareImageButton,
              variant: AppButtonVariant.secondary,
              icon: Icons.image_outlined,
              onPressed: () async {
                await capturePngBytes();
                await _copyAndNotify(shareText);
              },
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
          onPressed: () => _copyAndNotify(shareText),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/status_and_urgency_tags.dart';
import 'package:turkiye_kan_agi/features/matching/domain/blood_compatibility_engine.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Uygulamanın kalbi olan Kan Talebi Kartı (RequestCard):
/// - Sol büyük BloodTypeBadge (Hero destekli)
/// - Sağda hastane adı (max 2 satır, ellipsis), "ilçe • mesafe", "2 ünite trombosit"
/// - Alt satırda UrgencyTag + kalan süre + VerifiedBadge
/// - Sağ üstte "Uyumlusun" etiketi (kullanıcının kan grubu uyumluysa)
/// - ACİL kartın sol kenarında ince kırmızı şerit
class RequestCard extends StatelessWidget {
  const RequestCard({
    required this.request,
    super.key,
    this.userBloodType = BloodType.aPos,
    this.distanceKm = 3.2,
    this.onTap,
    this.enableHero = true,
  });

  final BloodRequest request;
  final BloodType userBloodType;
  final double distanceKm;
  final VoidCallback? onTap;
  final bool enableHero;

  String _productLabel(BuildContext context, BloodProductType type) {
    final l10n = context.l10n;
    return switch (type) {
      BloodProductType.wholeBlood => l10n.productWholeBlood,
      BloodProductType.erythrocyte => l10n.productErythrocyte,
      BloodProductType.platelet => l10n.productPlatelet,
      BloodProductType.plasma => l10n.productPlasma,
    };
  }

  String _remainingTimeText(BuildContext context) {
    final l10n = context.l10n;
    final diff = request.expiresAt.difference(DateTime.now().toUtc());
    if (diff.isNegative) return l10n.statusExpired;
    if (diff.inHours < 24) {
      return l10n.requestRemainingHours(diff.inHours.clamp(1, 24));
    }
    return l10n.requestRemainingDays((diff.inHours / 24).ceil());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final isCritical = request.urgency == RequestUrgency.critical;
    final isCompatible = BloodCompatibilityEngine.isCompatible(
      donor: userBloodType,
      recipient: request.bloodType,
      productType: request.productType,
    );

    final badge = BloodTypeBadge(
      bloodType: request.bloodType,
      size: BloodBadgeSize.m,
    );

    return AppCard(
      key: Key('request_card_${request.id}'),
      onTap: onTap,
      leftStripeColor: isCritical ? AppColors.primary : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          enableHero
              ? Hero(
                  tag: 'blood_badge_${request.id}',
                  child: badge,
                )
              : badge,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        request.hospital.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                    ),
                    if (isCompatible) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const CompatibleBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${request.hospital.district} / ${request.hospital.province} • ${distanceKm.toStringAsFixed(1)} km',
                  style: textTheme.labelMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${l10n.requestUnitsValue(request.unitsNeeded)} ${_productLabel(context, request.productType)}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    UrgencyTag(urgency: request.urgency),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 15),
                        const SizedBox(width: 2),
                        Text(
                          _remainingTimeText(context),
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const VerifiedBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

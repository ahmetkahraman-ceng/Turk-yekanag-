import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/status_and_urgency_tags.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';

/// Profesyonel Dijital Kan Bağışçısı Kimlik Kartı.
/// Tüm metrikleri (`donationCount`, `weightKg`, `remainingDays`, `isEligibleNow`)
/// tek doğruluk kaynağından alır.
class DonorIdentityCard extends StatelessWidget {
  const DonorIdentityCard({
    required this.initials,
    required this.fullName,
    required this.phone,
    required this.province,
    required this.district,
    required this.weightKg,
    required this.donationCount,
    required this.remainingDays,
    required this.isEligibleNow,
    required this.bloodType,
    required this.isAvailable,
    required this.isLocating,
    required this.verifiedLabel,
    required this.onUpdateGpsLocation,
    required this.onEditProfile,
    required this.onOpenDonationTab,
    super.key,
    this.gpsCoordinates,
  });

  final String initials;
  final String fullName;
  final String phone;
  final String province;
  final String district;
  final int weightKg;
  final int donationCount;
  final int remainingDays;
  final bool isEligibleNow;
  final BloodType bloodType;
  final bool isAvailable;
  final bool isLocating;
  final String verifiedLabel;
  final String? gpsCoordinates;
  final VoidCallback onUpdateGpsLocation;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenDonationTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final statusValue = isEligibleNow && isAvailable
        ? l10n.donorStatusEligibleCard
        : (remainingDays > 0
            ? l10n.donationDaysRemaining(remainingDays)
            : l10n.requestFilterAll);
    final statusColor =
        isEligibleNow && isAvailable ? AppColors.success : AppColors.warning;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        VerifiedBadge(label: verifiedLabel),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: AppRadius.chipBorder,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$district / $province',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BloodTypeBadge(
                bloodType: bloodType,
                size: BloodBadgeSize.m,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onOpenDonationTab,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: ProfileMetricItem(
                        label: l10n.navDonation,
                        value: '$donationCount',
                        icon: Icons.bloodtype_rounded,
                      ),
                    ),
                    const VerticalDivider(width: 16),
                    Expanded(
                      child: ProfileMetricItem(
                        label: l10n.wizardWeightLabel,
                        value: '$weightKg kg',
                        icon: Icons.monitor_weight_outlined,
                      ),
                    ),
                    const VerticalDivider(width: 16),
                    Expanded(
                      child: ProfileMetricItem(
                        label: l10n.donationTitle,
                        value: statusValue,
                        icon: isEligibleNow && isAvailable
                            ? Icons.check_circle_rounded
                            : Icons.hourglass_top_rounded,
                        valueColor: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('profile_update_gps_location_button'),
                  onPressed: isLocating ? null : onUpdateGpsLocation,
                  icon: isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    l10n.locationPermissionAllowButton,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: FilledButton.tonalIcon(
                  key: const Key('profile_quick_edit_button'),
                  onPressed: onEditProfile,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    l10n.profileEditButton,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileMetricItem extends StatelessWidget {
  const ProfileMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: valueColor ?? theme.colorScheme.primary,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

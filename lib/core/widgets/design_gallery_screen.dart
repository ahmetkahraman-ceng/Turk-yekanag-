import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/branding/blood_logo.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_chip.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/countdown_ring.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/core/widgets/skeleton_widgets.dart';
import 'package:turkiye_kan_agi/core/widgets/status_and_urgency_tags.dart';
import 'package:turkiye_kan_agi/core/widgets/step_and_progress.dart';
import 'package:turkiye_kan_agi/core/widgets/tiles_and_selection_sheet.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_status.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Debug-only tasarım galerisi ekranı (`/debug/gallery`).
/// Tüm ortak bileşenlerin örneklerini aydınlık/karanlık temada sergiler.
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  bool _switchValue = true;
  int _radioValue = 1;
  bool _chipSelected = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.designGalleryTitle)),
      body: ResponsiveConstrainedBox(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const OfflineBanner(forceShow: true),
            const SizedBox(height: AppSpacing.md),
            SectionHeader(title: l10n.appTitle, subtitle: l10n.splashSubtitle),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BloodLogo(size: 64),
                BloodLogo(size: 64, progress: 0.5),
                CountdownRing(
                  progress: 0.72,
                  centerText: '24 gün',
                  size: 84,
                  strokeWidth: 8,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'BloodTypeBadge (8 Grup)'),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final bt in BloodType.knownValues)
                  BloodTypeBadge(bloodType: bt, size: BloodBadgeSize.m),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'UrgencyTag & StatusTag'),
            const Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                UrgencyTag(urgency: RequestUrgency.critical),
                UrgencyTag(urgency: RequestUrgency.today),
                UrgencyTag(urgency: RequestUrgency.thisWeek),
                StatusTag(status: RequestStatus.open),
                StatusTag(status: RequestStatus.fulfilled),
                StatusTag(status: RequestStatus.cancelled),
                StatusTag(status: RequestStatus.expired),
                VerifiedBadge(),
                CompatibleBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'AppButton Varyantları'),
            AppButton(label: l10n.actionWantBlood, onPressed: () {}),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l10n.actionCanHelp,
              variant: AppButtonVariant.secondary,
              icon: Icons.favorite_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l10n.requestCancelButton,
              variant: AppButtonVariant.danger,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Form & Seçim Bileşenleri'),
            AppTextField.phone(labelText: l10n.authPhoneLabel),
            const SizedBox(height: AppSpacing.xs),
            AppSearchField(hintText: l10n.requestHospitalSearchHint),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                AppChip(
                  label: l10n.filterMyBloodGroup,
                  selected: _chipSelected,
                  onSelected: (v) => setState(() => _chipSelected = v),
                ),
                AppChip(label: l10n.urgencyCriticalShort, selected: false),
              ],
            ),
            SwitchTile(
              title: l10n.profileAvailableSwitchTitle,
              value: _switchValue,
              onChanged: (v) => setState(() => _switchValue = v),
            ),
            RadioTile<int>(
              title: l10n.urgencyCritical,
              value: 1,
              groupValue: _radioValue,
              onChanged: (v) => setState(() => _radioValue = v ?? 1),
            ),
            const SizedBox(height: AppSpacing.md),
            const StepIndicator(totalSteps: 4, currentStep: 2),
            const SizedBox(height: AppSpacing.sm),
            const Center(child: ProgressDots(count: 4, currentIndex: 1)),
            const SizedBox(height: AppSpacing.md),
            const AppCard(
              child: RequestCardSkeleton(),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 220,
              child: EmptyState(
                title: l10n.requestsNoOpenNearYouTitle,
                subtitle: l10n.requestsNoOpenNearYouSubtitle,
              ),
            ),
            SizedBox(
              height: 220,
              child: ErrorState(
                message: l10n.commonErrorMessage,
                onRetry: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

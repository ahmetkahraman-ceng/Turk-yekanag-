import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/matching/data/firestore_matching_repository.dart';
import 'package:turkiye_kan_agi/features/matching/domain/blood_compatibility_engine.dart';
import 'package:turkiye_kan_agi/features/matching/domain/donation_offer.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';

/// Talep detay ekranında yer alan Bağışçı Teklif, Saat Koordinasyonu,
/// Durum Adımları ve Talep Sahibi Onay / Karşılıklı İletişim paneli.
class DonorOfferPanel extends ConsumerStatefulWidget {
  const DonorOfferPanel({
    required this.request,
    required this.donorBloodType,
    required this.onOffersChanged,
    super.key,
  });

  final BloodRequest request;
  final BloodType donorBloodType;
  final VoidCallback onOffersChanged;

  @override
  ConsumerState<DonorOfferPanel> createState() => _DonorOfferPanelState();
}

class _DonorOfferPanelState extends ConsumerState<DonorOfferPanel> {
  DonationTimeSlot _selectedSlot = DonationTimeSlot.immediate;
  List<DonationOffer> _offers = const <DonationOffer>[];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final res = await ref
        .read(matchingRepositoryProvider)
        .getOffersForRequest(widget.request.id);
    if (!mounted) return;
    res.when(
      success: (list) => setState(() => _offers = list),
      failure: (_) {},
    );
  }

  String _slotLabel(BuildContext context, DonationTimeSlot slot) {
    final l10n = context.l10n;
    return switch (slot) {
      DonationTimeSlot.immediate => l10n.matchingTimeSlotNow,
      DonationTimeSlot.morning => l10n.matchingTimeSlotMorning,
      DonationTimeSlot.afternoon => l10n.matchingTimeSlotAfternoon,
      DonationTimeSlot.evening => l10n.matchingTimeSlotEvening,
    };
  }

  Future<void> _submitOffer(String uid) async {
    await ref.read(matchingRepositoryProvider).submitHelpOffer(
          requestId: widget.request.id,
          donorUid: uid,
          donorDisplayName: 'Gönüllü Bağışçı',
          donorBloodType: widget.donorBloodType,
          timeSlot: _selectedSlot,
        );
    await _loadOffers();
    widget.onOffersChanged();
  }

  Future<void> _advanceStep(
    String uid,
    DonationOfferStatus status, {
    String? quickMsg,
  }) async {
    await ref.read(matchingRepositoryProvider).updateDonorStep(
          requestId: widget.request.id,
          donorUid: uid,
          nextStatus: status,
          quickMessage: quickMsg,
        );
    await _loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currentUid = ref.watch(currentUserIdStateProvider) ?? 'local-user';
    final isOwner = widget.request.requesterUid == currentUid;
    final isCompatible = BloodCompatibilityEngine.isCompatible(
      donor: widget.donorBloodType,
      recipient: widget.request.bloodType,
      productType: widget.request.productType,
    );
    final myOffer =
        _offers.where((o) => o.donorUid == currentUid).firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOwner) ...[
              Text(
                isCompatible
                    ? l10n.matchingCompatibilityCompatible
                    : l10n.matchingCompatibilityIncompatible(
                        widget.donorBloodType.code,
                        widget.request.bloodType.code,
                        widget.request.productType.code,
                      ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCompatible
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (widget.request.stopNewOffers && myOffer == null)
                Text(l10n.matchingOffersClosedNotice)
              else if (myOffer == null) ...[
                Text(
                  l10n.matchingSelectTimeSlotTitle,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final slot in DonationTimeSlot.values)
                      ChoiceChip(
                        key: Key('time_slot_chip_${slot.code}'),
                        label: Text(_slotLabel(context, slot)),
                        selected: _selectedSlot == slot,
                        onSelected: (_) => setState(() => _selectedSlot = slot),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(
                  key: const Key('can_help_button'),
                  icon: Icons.volunteer_activism_rounded,
                  label: l10n.matchingCanHelpButton,
                  onPressed: () => _submitOffer(currentUid),
                ),
              ] else ...[
                Text(
                  myOffer.isContactVisible
                      ? l10n.matchingOfferApproved
                      : l10n.matchingOfferPending,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    ActionChip(
                      key: const Key('donor_step_on_the_way'),
                      label: Text(l10n.matchingStepOnTheWay),
                      onPressed: () => _advanceStep(
                        currentUid,
                        DonationOfferStatus.onTheWay,
                        quickMsg: l10n.matchingQuickMsg1,
                      ),
                    ),
                    ActionChip(
                      key: const Key('donor_step_arrived'),
                      label: Text(l10n.matchingStepArrived),
                      onPressed: () => _advanceStep(
                        currentUid,
                        DonationOfferStatus.arrivedAtHospital,
                        quickMsg: l10n.matchingQuickMsg2,
                      ),
                    ),
                    ActionChip(
                      key: const Key('donor_step_donated'),
                      label: Text(l10n.matchingStepDonated),
                      onPressed: () => _advanceStep(
                        currentUid,
                        DonationOfferStatus.donatedPendingConfirmation,
                        quickMsg: l10n.matchingQuickMsg3,
                      ),
                    ),
                  ],
                ),
                if (myOffer.isContactVisible) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        key: const Key('mutual_call_button'),
                        onPressed: () {},
                        icon: const Icon(Icons.phone_rounded),
                        label: Text(
                          '${l10n.matchingCallButton} (${myOffer.requesterPhone ?? ""})',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        key: const Key('mutual_whatsapp_button'),
                        onPressed: () {},
                        icon: const Icon(Icons.chat_rounded),
                        label: Text(l10n.matchingWhatsAppButton),
                      ),
                    ],
                  ),
                ],
              ],
              const Divider(height: AppSpacing.lg),
            ],
            for (final offer in _offers)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${offer.donorDisplayName} (${offer.donorBloodType.code}) • ${_slotLabel(context, offer.timeSlot)}',
                ),
                subtitle: Text(
                  offer.quickMessage.isNotEmpty
                      ? offer.quickMessage
                      : offer.status.code,
                ),
                trailing: isOwner
                    ? (offer.status == DonationOfferStatus.pending
                        ? TextButton(
                            key: Key('approve_donor_${offer.donorUid}'),
                            onPressed: () async {
                              await ref
                                  .read(matchingRepositoryProvider)
                                  .approveDonorAndUnlockContacts(
                                    requestId: widget.request.id,
                                    donorUid: offer.donorUid,
                                  );
                              await _loadOffers();
                            },
                            child: Text(l10n.matchingOwnerApproveDonorButton),
                          )
                        : offer.status != DonationOfferStatus.confirmed
                            ? TextButton(
                                key: Key('confirm_donation_${offer.donorUid}'),
                                onPressed: () async {
                                  await ref
                                      .read(matchingRepositoryProvider)
                                      .confirmDonationAndRecordHistory(
                                        requestId: widget.request.id,
                                        donorUid: offer.donorUid,
                                        hospitalName:
                                            widget.request.hospital.name,
                                      );
                                  await _loadOffers();
                                },
                                child: Text(
                                  l10n.matchingOwnerConfirmDonationButton,
                                ),
                              )
                            : const Icon(Icons.verified_rounded))
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

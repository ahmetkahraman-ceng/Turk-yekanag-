import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Manuel bağış ekleme alt penceresi (BottomSheet) verisi.
class ManualDonationInput {
  const ManualDonationInput({
    required this.donatedAt,
    required this.place,
    required this.productType,
  });

  final DateTime donatedAt;
  final String place;
  final BloodProductType productType;
}

/// Kullanıcının geçmişte yaptığı bağışı (tarih, yer, ürün tipi) manuel eklediği form.
class AddDonationSheet extends StatefulWidget {
  const AddDonationSheet({
    super.key,
    this.initialDate,
  });

  final DateTime? initialDate;

  @override
  State<AddDonationSheet> createState() => _AddDonationSheetState();
}

class _AddDonationSheetState extends State<AddDonationSheet> {
  final TextEditingController _placeController = TextEditingController();
  late DateTime _selectedDate;
  BloodProductType _selectedProduct = BloodProductType.wholeBlood;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(now) ? now : _selectedDate,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _errorText = null;
      });
    }
  }

  void _onSave() {
    final l10n = context.l10n;
    final place = _placeController.text.trim();
    if (place.isEmpty) {
      setState(() => _errorText = l10n.donationValidationPlaceRequired);
      return;
    }
    if (_selectedDate.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      setState(() => _errorText = l10n.donationValidationFutureDate);
      return;
    }
    Navigator.of(context).pop(
      ManualDonationInput(
        donatedAt: _selectedDate.toUtc(),
        place: place,
        productType: _selectedProduct,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat.yMMMd(localeName).format(_selectedDate);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.donationAddSheetTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                key: const Key('manual_donation_place_field'),
                controller: _placeController,
                labelText: l10n.donationPlaceLabel,
                hintText: l10n.donationPlaceHint,
                errorText: _errorText,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.donationDateLabel}: $formattedDate',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const Key('manual_donation_date_button'),
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_rounded),
                    label: Text(l10n.donationSelectDateButton),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.donationProductTypeLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final type in BloodProductType.values)
                    ChoiceChip(
                      key: Key('manual_product_chip_${type.code}'),
                      label: Text(_productLabel(context, type)),
                      selected: _selectedProduct == type,
                      onSelected: (_) =>
                          setState(() => _selectedProduct = type),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                key: const Key('save_manual_donation_button'),
                icon: Icons.check_rounded,
                label: l10n.commonSave,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_chip.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Filtre Bottom Sheet'i:
/// Kan grubu çoklu seçim, ürün tipi, aciliyet, mesafe kaydırıcısı (3/10/25/50 km/tüm şehir),
/// "Uygula" ve "Temizle".
class RequestFilterSheetResult {
  const RequestFilterSheetResult({
    required this.filter,
    required this.selectedBloodTypes,
    required this.maxDistanceKm,
  });

  final BloodRequestFilter filter;
  final Set<BloodType> selectedBloodTypes;

  /// null ise "Tüm Şehir".
  final double? maxDistanceKm;
}

class RequestFilterSheet extends StatefulWidget {
  const RequestFilterSheet({
    required this.initialFilter,
    super.key,
    this.initialBloodTypes = const <BloodType>{},
    this.initialDistanceKm,
  });

  final BloodRequestFilter initialFilter;
  final Set<BloodType> initialBloodTypes;
  final double? initialDistanceKm;

  static Future<RequestFilterSheetResult?> show({
    required BuildContext context,
    required BloodRequestFilter initialFilter,
    Set<BloodType> initialBloodTypes = const <BloodType>{},
    double? initialDistanceKm,
  }) {
    return AppBottomSheet.show<RequestFilterSheetResult>(
      context: context,
      builder: (_) => RequestFilterSheet(
        initialFilter: initialFilter,
        initialBloodTypes: initialBloodTypes,
        initialDistanceKm: initialDistanceKm,
      ),
    );
  }

  @override
  State<RequestFilterSheet> createState() => _RequestFilterSheetState();
}

class _RequestFilterSheetState extends State<RequestFilterSheet> {
  static const List<double?> _distanceSteps = [3, 10, 25, 50, null];

  late Set<BloodType> _bloodTypes = Set<BloodType>.of(widget.initialBloodTypes);
  late BloodProductType? _productType = widget.initialFilter.productType;
  late RequestUrgency? _urgency = widget.initialFilter.urgency;
  late int _distanceStepIndex = _resolveStepIndex(widget.initialDistanceKm);

  int _resolveStepIndex(double? km) {
    final idx = _distanceSteps.indexOf(km);
    return idx == -1 ? 4 : idx;
  }

  void _clearAll() {
    setState(() {
      _bloodTypes.clear();
      _productType = null;
      _urgency = null;
      _distanceStepIndex = 4;
    });
  }

  void _apply() {
    final firstBt = _bloodTypes.length == 1 ? _bloodTypes.first : null;
    final updated = widget.initialFilter.copyWith(
      bloodType: firstBt,
      clearBloodType: firstBt == null,
      productType: _productType,
      clearProductType: _productType == null,
      urgency: _urgency,
      clearUrgency: _urgency == null,
    );
    Navigator.of(context).pop(
      RequestFilterSheetResult(
        filter: updated,
        selectedBloodTypes: _bloodTypes,
        maxDistanceKm: _distanceSteps[_distanceStepIndex],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentKm = _distanceSteps[_distanceStepIndex];
    final distanceLabel = currentKm == null
        ? l10n.filterDistanceAllCity
        : l10n.notifRadiusKm(currentKm.toInt());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionHeader(
            title: l10n.requestFilterBloodGroup,
            trailing: TextButton(
              onPressed: _clearAll,
              child: Text(l10n.filterClearButton),
            ),
          ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final bt in BloodType.knownValues)
                AppChip(
                  label: bt.code,
                  selected: _bloodTypes.contains(bt),
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _bloodTypes.add(bt);
                      } else {
                        _bloodTypes.remove(bt);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(title: l10n.requestFilterProduct),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final p in [
                (BloodProductType.wholeBlood, l10n.productWholeBlood),
                (BloodProductType.erythrocyte, l10n.productErythrocyte),
                (BloodProductType.platelet, l10n.productPlatelet),
                (BloodProductType.plasma, l10n.productPlasma),
              ])
                AppChip(
                  label: p.$2,
                  selected: _productType == p.$1,
                  onSelected: (sel) =>
                      setState(() => _productType = sel ? p.$1 : null),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(title: l10n.requestFilterUrgency),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final u in [
                (RequestUrgency.critical, l10n.urgencyCriticalShort),
                (RequestUrgency.today, l10n.urgencyTodayShort),
                (RequestUrgency.thisWeek, l10n.urgencyThisWeekShort),
              ])
                AppChip(
                  label: u.$2,
                  selected: _urgency == u.$1,
                  onSelected: (sel) =>
                      setState(() => _urgency = sel ? u.$1 : null),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(
            title: l10n.filterDistanceTitle,
            trailing: Text(
              distanceLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Slider(
            value: _distanceStepIndex.toDouble(),
            min: 0,
            max: 4,
            divisions: 4,
            label: distanceLabel,
            onChanged: (val) =>
                setState(() => _distanceStepIndex = val.round()),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.filterApplyButton,
            enableHaptic: true,
            onPressed: _apply,
          ),
        ],
      ),
    );
  }
}

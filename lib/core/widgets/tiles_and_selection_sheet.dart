import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';

/// Erişilebilirlik uyumlu Switch satırı.
class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        secondary: icon != null ? Icon(icon) : null,
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        value: value,
        onChanged: onChanged,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
      ),
    );
  }
}

/// Erişilebilirlik uyumlu Radio satırı.
class RadioTile<T> extends StatelessWidget {
  const RadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_off_rounded,
          color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onChanged != null ? () => onChanged!(value) : null,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
      ),
    );
  }
}

/// Aramalı il / ilçe / hastane seçici Bottom Sheet.
class SelectionSheet<T> extends StatefulWidget {
  const SelectionSheet({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.labelBuilder,
    super.key,
    this.subtitleBuilder,
    this.selectedItem,
  });

  final String title;
  final String searchHint;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final String? Function(T item)? subtitleBuilder;
  final T? selectedItem;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String searchHint,
    required List<T> items,
    required String Function(T item) labelBuilder,
    String? Function(T item)? subtitleBuilder,
    T? selectedItem,
  }) {
    return AppBottomSheet.show<T>(
      context: context,
      builder: (_) => SelectionSheet<T>(
        title: title,
        searchHint: searchHint,
        items: items,
        labelBuilder: labelBuilder,
        subtitleBuilder: subtitleBuilder,
        selectedItem: selectedItem,
      ),
    );
  }

  @override
  State<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<SelectionSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((item) {
      final label = widget.labelBuilder(item).toLowerCase();
      final sub = widget.subtitleBuilder?.call(item)?.toLowerCase() ?? '';
      return label.contains(q) || sub.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSearchField(
              hintText: widget.searchHint,
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final label = widget.labelBuilder(item);
                  final subtitle = widget.subtitleBuilder?.call(item);
                  final isSelected = item == widget.selectedItem;
                  return ListTile(
                    title: Text(label),
                    subtitle: subtitle != null ? Text(subtitle) : null,
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

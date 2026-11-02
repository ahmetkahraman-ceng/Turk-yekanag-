import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/widgets/feature_placeholder_view.dart';

/// Harita sekmesi başlangıç ekranı.
class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    this.initialState = ScreenViewState.empty,
  });

  final ScreenViewState initialState;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FeaturePlaceholderView(
      title: l10n.mapTitle,
      emptyTitle: l10n.mapEmptyTitle,
      emptySubtitle: l10n.mapEmptySubtitle,
      icon: Icons.map_outlined,
      initialState: initialState,
    );
  }
}

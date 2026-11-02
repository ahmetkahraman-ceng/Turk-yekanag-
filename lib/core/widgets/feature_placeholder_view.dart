import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/theme/theme_mode_provider.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/loading_skeleton.dart';

/// İskelet ekranların desteklediği görünüm durumları.
enum ScreenViewState {
  empty,
  loading,
  error,
}

/// Her ekranda loading (skeleton), empty ve error durumlarını standartlaştıran iskelet görünüm.
class FeaturePlaceholderView extends ConsumerStatefulWidget {
  const FeaturePlaceholderView({
    required this.title,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.icon,
    super.key,
    this.initialState = ScreenViewState.empty,
    this.footerNote,
  });

  final String title;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData icon;
  final ScreenViewState initialState;
  final String? footerNote;

  @override
  ConsumerState<FeaturePlaceholderView> createState() =>
      _FeaturePlaceholderViewState();
}

class _FeaturePlaceholderViewState
    extends ConsumerState<FeaturePlaceholderView> {
  late ScreenViewState _viewState;

  @override
  void initState() {
    super.initState();
    _viewState = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Semantics(
            button: true,
            label: l10n.themeToggleSemantics,
            child: IconButton(
              icon: Icon(
                theme.brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                ref
                    .read(themeModeProvider.notifier)
                    .toggleTheme(theme.brightness);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: SegmentedButton<ScreenViewState>(
              segments: [
                ButtonSegment(
                  value: ScreenViewState.empty,
                  label: Text(l10n.statePreviewEmpty),
                  icon: const Icon(Icons.inbox_outlined),
                ),
                ButtonSegment(
                  value: ScreenViewState.loading,
                  label: Text(l10n.statePreviewLoading),
                  icon: const Icon(Icons.hourglass_top_rounded),
                ),
                ButtonSegment(
                  value: ScreenViewState.error,
                  label: Text(l10n.statePreviewError),
                  icon: const Icon(Icons.error_outline_rounded),
                ),
              ],
              selected: {_viewState},
              onSelectionChanged: (selection) {
                setState(() {
                  _viewState = selection.first;
                });
              },
            ),
          ),
          Expanded(
            child: _buildBody(l10n),
          ),
          if (widget.footerNote != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                widget.footerNote!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    switch (_viewState) {
      case ScreenViewState.loading:
        return const LoadingSkeleton(itemCount: 4);
      case ScreenViewState.error:
        return ErrorState(
          message: l10n.commonErrorMessage,
          onRetry: () {
            setState(() {
              _viewState = ScreenViewState.empty;
            });
          },
        );
      case ScreenViewState.empty:
        return EmptyState(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          icon: widget.icon,
        );
    }
  }
}

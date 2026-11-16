import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/skeleton_widgets.dart';

/// Büyük ekranlarda içeriği maksimum 600dp genişlikte ve ortalı tutan sarmalayıcı.
class ResponsiveConstrainedBox extends StatelessWidget {
  const ResponsiveConstrainedBox({
    required this.child,
    super.key,
    this.maxWidth = AppSpacing.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// AsyncValue.when yerine kullanılan merkezi görünüm bileşeni:
/// loading = SkeletonList, error = ErrorState, empty = EmptyState, data = builder.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    super.key,
    this.isEmpty,
    this.emptyState,
    this.loadingSkeleton,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final Widget? emptyState;
  final Widget? loadingSkeleton;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (value.isLoading && !value.hasValue) {
      return loadingSkeleton ?? const SkeletonList();
    }

    if (value.hasError && !value.hasValue) {
      return ErrorState(
        title: l10n.commonErrorTitle,
        message: l10n.commonErrorMessage,
        onRetry: onRetry,
      );
    }

    final resolved = value.valueOrNull;
    if (resolved == null || (isEmpty != null && isEmpty!(resolved))) {
      return emptyState ??
          EmptyState(
            title: l10n.requestsNoOpenNearYouTitle,
            subtitle: l10n.requestsNoOpenNearYouSubtitle,
          );
    }

    return data(resolved);
  }
}

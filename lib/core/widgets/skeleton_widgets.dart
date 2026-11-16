import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// Tek bir paylaşılan AnimationController sağlayan skeleton sarmalayıcısı.
class SkeletonPulseScope extends StatefulWidget {
  const SkeletonPulseScope({
    required this.child,
    super.key,
  });

  final Widget child;

  static Animation<double>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedSkeletonPulse>()
        ?.animation;
  }

  @override
  State<SkeletonPulseScope> createState() => _SkeletonPulseScopeState();
}

class _SkeletonPulseScopeState extends State<SkeletonPulseScope>
     with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedSkeletonPulse(
      animation: _controller,
      child: widget.child,
    );
  }
}

class _InheritedSkeletonPulse extends InheritedWidget {
  const _InheritedSkeletonPulse({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  @override
  bool updateShouldNotify(covariant _InheritedSkeletonPulse oldWidget) {
    return oldWidget.animation != animation;
  }
}

/// Tekil iskelet kutusu.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 18.0,
    this.borderRadius = AppRadius.sm,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBaseLight;
    final highlightColor = isDark
        ? AppColors.skeletonHighlightDark
        : AppColors.skeletonHighlightLight;

    final animation = SkeletonPulseScope.maybeOf(context);
    if (animation == null || AppMotion.isAnimationsDisabled(context)) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Color.lerp(baseColor, highlightColor, animation.value),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );
        },
      ),
    );
  }
}

/// RequestCard görünümüne birebir uyan iskelet kart.
class RequestCardSkeleton extends StatelessWidget {
  const RequestCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 52, height: 52, borderRadius: 26),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 190, height: 18),
                SizedBox(height: AppSpacing.xs),
                SkeletonBox(width: 130, height: 14),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    SkeletonBox(width: 68, height: 24, borderRadius: 999),
                    SizedBox(width: AppSpacing.xs),
                    SkeletonBox(width: 84, height: 16),
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

/// Paylaşılan tek AnimationController kullanan iskelet listesi.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 4,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.commonLoading,
      liveRegion: true,
      child: SkeletonPulseScope(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, __) => const RequestCardSkeleton(),
        ),
      ),
    );
  }
}

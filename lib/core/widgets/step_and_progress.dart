import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// Çok adımlı akışlar (sihirbaz ve bağış takibi) için adım göstergesi.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    required this.totalSteps,
    required this.currentStep,
    super.key,
    this.labels,
  });

  final int totalSteps;
  final int currentStep;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dur = AppMotion.resolveDuration(context, AppMotion.normal);

    return Semantics(
      label: 'Adım ${currentStep + 1} / $totalSteps',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final isDone = index < currentStep;
              final isCurrent = index == currentStep;
              final color = isDone
                  ? AppColors.success
                  : isCurrent
                      ? scheme.primary
                      : scheme.surfaceContainerHighest;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == totalSteps - 1 ? 0 : AppSpacing.xs,
                  ),
                  child: AnimatedContainer(
                    duration: dur,
                    curve: AppMotion.outCurve,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: AppRadius.chipBorder,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (labels != null &&
              currentStep >= 0 &&
              currentStep < labels!.length) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              labels![currentStep],
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Onboarding ve karuseller için nokta ilerleme göstergesi.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    required this.count,
    required this.currentIndex,
    super.key,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dur = AppMotion.resolveDuration(context, AppMotion.normal);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = index == currentIndex;
        return AnimatedContainer(
          duration: dur,
          curve: AppMotion.outCurve,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          height: 8,
          width: active ? 28 : 8,
          decoration: BoxDecoration(
            color: active ? scheme.primary : scheme.outline,
            borderRadius: AppRadius.chipBorder,
          ),
        );
      }),
    );
  }
}

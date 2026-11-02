import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';

/// 4 slaytlık uygulama tanıtım (Onboarding) ekranı.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).markCompleted();
    context.go(AppRoutes.kvkkConsent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final slides = <_OnboardingSlideData>[
      _OnboardingSlideData(
        icon: Icons.volunteer_activism_rounded,
        title: l10n.onboardingSlide1Title,
        description: l10n.onboardingSlide1Description,
      ),
      _OnboardingSlideData(
        icon: Icons.hub_rounded,
        title: l10n.onboardingSlide2Title,
        description: l10n.onboardingSlide2Description,
      ),
      _OnboardingSlideData(
        icon: Icons.shield_outlined,
        title: l10n.onboardingSlide3Title,
        description: l10n.onboardingSlide3Description,
      ),
      _OnboardingSlideData(
        icon: Icons.location_city_rounded,
        title: l10n.onboardingSlide4Title,
        description: l10n.onboardingSlide4Description,
      ),
    ];

    final isLastSlide = _currentIndex == slides.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (!isLastSlide)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(l10n.commonSkip),
            ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        slide.icon,
                        size: 96,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        slide.title,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        slide.description,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => Container(
                      width: _currentIndex == index ? 24 : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: isLastSlide
                      ? l10n.onboardingStartAction
                      : l10n.commonNext,
                  onPressed: () {
                    if (isLastSlide) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

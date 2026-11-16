import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/step_and_progress.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/widgets/onboarding_illustrations.dart';

/// 4 slaytlık uygulama tanıtım (Onboarding) ekranı.
/// CustomPainter illüstrasyonlar, hafif parallax, ProgressDots, Atla ve İleri/Başla.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || !_pageController.hasClients) return;
    setState(() {
      _pageOffset = _pageController.page ?? _currentIndex.toDouble();
    });
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onScroll)
      ..dispose();
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
        illustration: OnboardingIllustrationType.drop,
        title: l10n.onboardingV2Slide1Title,
        description: l10n.onboardingV2Slide1Body,
      ),
      _OnboardingSlideData(
        illustration: OnboardingIllustrationType.mapPin,
        title: l10n.onboardingV2Slide2Title,
        description: l10n.onboardingV2Slide2Body,
      ),
      _OnboardingSlideData(
        illustration: OnboardingIllustrationType.handshake,
        title: l10n.onboardingV2Slide3Title,
        description: l10n.onboardingV2Slide3Body,
      ),
      _OnboardingSlideData(
        illustration: OnboardingIllustrationType.shield,
        title: l10n.onboardingV2Slide4Title,
        description: l10n.onboardingV2Slide4Body,
      ),
    ];

    final isLastSlide = _currentIndex == slides.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (!isLastSlide)
            TextButton(
              key: const Key('onboarding_skip_button'),
              onPressed: _completeOnboarding,
              child: Text(l10n.commonSkip),
            ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  final delta = (index - _pageOffset).clamp(-1.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OnboardingIllustration(
                          type: slide.illustration,
                          parallaxOffset: delta,
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
          ),
          SafeArea(
            top: false,
            child: ResponsiveConstrainedBox(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  ProgressDots(
                    count: slides.length,
                    currentIndex: _currentIndex,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const Key('onboarding_primary_button'),
                    label: isLastSlide
                        ? l10n.onboardingStartButton
                        : l10n.commonNext,
                    enableHaptic: true,
                    onPressed: () {
                      if (isLastSlide) {
                        _completeOnboarding();
                      } else {
                        final dur = AppMotion.resolveDuration(
                          context,
                          AppMotion.normal,
                        );
                        if (dur == Duration.zero) {
                          _pageController.jumpToPage(_currentIndex + 1);
                        } else {
                          _pageController.nextPage(
                            duration: dur,
                            curve: AppMotion.inOutCurve,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.illustration,
    required this.title,
    required this.description,
  });

  final OnboardingIllustrationType illustration;
  final String title;
  final String description;
}

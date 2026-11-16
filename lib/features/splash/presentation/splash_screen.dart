import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/branding/blood_logo.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/app_version_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/theme/app_typography.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';

/// Soğuk açılış kontrolü sağlayıcısı (yalnızca soğuk açılışta bir kez oynatılır).
final coldStartSplashCompletedProvider = StateProvider<bool>((ref) => false);

/// Animasyonlu Splash Ekranı (~2,6 sn, tek AnimationController + Interval):
/// - 0.0-0.5s: damla yukarıdan opacity 0->1
/// - 0.5-1.1s: damla merkeze düşer (easeIn), değince kırmızı dalga halkası + HapticFeedback.lightImpact
/// - 1.1-1.8s: ağ noktaları/çizgiler (progress 0->1) + iki kez kalp atışı (1.0->1.08->1.0)
/// - 1.8-2.6s: "Türkiye Kan Ağı" (Nunito 800, 28sp) + 150ms sonra "Bir damla, bir umut." (Nunito 500, 16sp)
/// - 2.6s aşılırsa altta 3 yanıp sönen nokta, en fazla 4sn bekleme.
/// - disableAnimations açıksa statik logo+yazı, 800ms sonra yönlendirme.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navigationTimer;
  Timer? _maxWaitTimer;
  bool _hapticTriggered = false;
  bool _showWaitingDots = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.splashTotal,
    )..addListener(_onAnimationTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSplashSequence();
    });
  }

  void _onAnimationTick() {
    // 1.1sn civarı (1.1 / 2.6 = 0.423) damla merkeze değdiğinde hafif titreşim
    if (!_hapticTriggered && _controller.value >= (1.1 / 2.6)) {
      _hapticTriggered = true;
      HapticFeedback.lightImpact();
    }
  }

  void _startSplashSequence() {
    final disableAnim = AppMotion.isAnimationsDisabled(context);
    if (disableAnim) {
      _controller.value = 1.0;
      _navigationTimer = Timer(AppMotion.splashReduced, _tryNavigate);
      return;
    }

    _controller.forward().whenComplete(() {
      if (!mounted) return;
      final forceUpdateAsync = ref.read(forceUpdateStatusProvider);
      if (forceUpdateAsync.isLoading) {
        setState(() => _showWaitingDots = true);
      } else {
        _tryNavigate();
      }
    });

    // En fazla 4 sn bekleme kuralı
    _maxWaitTimer = Timer(const Duration(milliseconds: 4000), _tryNavigate);
  }

  void _tryNavigate() {
    if (!mounted || _navigated) return;
    _navigated = true;
    ref.read(coldStartSplashCompletedProvider.notifier).state = true;

    final forceUpdate = ref.read(forceUpdateStatusProvider).valueOrNull;
    if (forceUpdate != null && forceUpdate.isRequired) {
      context.go(AppRoutes.forceUpdate);
      return;
    }

    final onboardingSeen = ref.read(onboardingCompletedProvider);
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final profileCompleted = ref.read(profileCompletedStateProvider);

    // Yönlendirme sırası:
    // onboarding görülmediyse onboarding -> giriş yoksa giriş -> profil eksikse sihirbaz -> ana ekran
    if (!isAuthenticated && !onboardingSeen) {
      context.go(AppRoutes.onboarding);
    } else if (!isAuthenticated) {
      context.go(AppRoutes.login);
    } else if (!profileCompleted) {
      context.go(AppRoutes.profileSetup);
    } else {
      context.go(AppRoutes.requests);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _maxWaitTimer?.cancel();
    _controller
      ..removeListener(_onAnimationTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen<AsyncValue<ForceUpdateStatus>>(
      forceUpdateStatusProvider,
      (_, next) {
        if (!next.isLoading && _controller.isCompleted) {
          _tryNavigate();
        }
      },
    );

    return Scaffold(
      body: Semantics(
        label: l10n.splashSemantics,
        liveRegion: true,
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return _SplashAnimatedBody(
                          progress: _controller.value,
                          title: l10n.appTitle,
                          subtitle: l10n.splashSubtitle,
                          showWaitingDots: _showWaitingDots,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashAnimatedBody extends StatelessWidget {
  const _SplashAnimatedBody({
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.showWaitingDots,
  });

  final double progress;
  final String title;
  final String subtitle;
  final bool showWaitingDots;

  double _interval(double startSec, double endSec, [Curve curve = Curves.linear]) {
    final start = (startSec / 2.6).clamp(0.0, 1.0);
    final end = (endSec / 2.6).clamp(0.0, 1.0);
    final t = ((progress - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  double _heartbeatScale() {
    // 1.1-1.8 sn aralığının ikinci yarısında (1.45-1.80) iki kez 1.0 -> 1.08 -> 1.0
    final t = _interval(1.45, 1.80);
    if (t <= 0 || t >= 1) return 1.0;
    final pulse = (t < 0.5) ? (t * 2) : ((t - 0.5) * 2);
    final wave = pulse < 0.5 ? (pulse * 2) : (1.0 - (pulse - 0.5) * 2);
    return 1.0 + 0.08 * wave;
  }

  @override
  Widget build(BuildContext context) {
    final dropOpacity = _interval(0.0, 0.5, Curves.easeOut);
    final dropFall = _interval(0.5, 1.1, Curves.easeIn);
    final rippleProgress = _interval(1.05, 1.55, Curves.easeOutCubic);
    final networkProgress = _interval(1.1, 1.65, Curves.easeInOutCubic);
    final titleProgress = _interval(1.8, 2.35, Curves.easeOutCubic);
    final subtitleProgress = _interval(1.95, 2.55, Curves.easeOutCubic);
    final scale = _heartbeatScale();

    final secondaryColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (rippleProgress > 0 && rippleProgress < 1.0)
                CustomPaint(
                  size: const Size.square(140),
                  painter: _SplashRipplePainter(progress: rippleProgress),
                ),
              Transform.translate(
                offset: Offset(0, -48 * (1.0 - dropFall)),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: dropOpacity,
                    child: BloodLogo(
                      size: 96,
                      progress: networkProgress,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Transform.translate(
          offset: Offset(0, 16 * (1.0 - titleProgress)),
          child: Opacity(
            opacity: titleProgress,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Transform.translate(
          offset: Offset(0, 16 * (1.0 - subtitleProgress)),
          child: Opacity(
            opacity: subtitleProgress,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: secondaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (showWaitingDots) const _BlinkingThreeDots(),
      ],
    );
  }
}

class _SplashRipplePainter extends CustomPainter {
  const _SplashRipplePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final radius = 34.0 + 36.0 * progress;
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: (1.0 - progress) * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashRipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BlinkingThreeDots extends StatelessWidget {
  const _BlinkingThreeDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

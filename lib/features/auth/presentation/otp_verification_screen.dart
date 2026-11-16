import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_motion.dart';
import 'package:turkiye_kan_agi/core/theme/app_radius.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/auth/data/firebase_auth_repository.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/login_screen.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/otp_timer_notifier.dart';

/// OTP ekranı:
/// 6 haneli kutular (otomatik odak, yapıştırma, SMS autofill),
/// "Kodu tekrar gönder (45 sn)" geri sayımı,
/// yanlış kodda sallanma animasyonu ve hata mesajı, doğrulanınca başarı tiki.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    required this.args,
    super.key,
  });

  final OtpRouteArgs args;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _shakeController;
  late String _verificationId;
  String? _otpError;
  bool _isLoading = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.args.verificationId;
    _shakeController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerErrorShake(String errorMsg) {
    HapticFeedback.heavyImpact();
    setState(() => _otpError = errorMsg);
    if (!AppMotion.isAnimationsDisabled(context)) {
      _shakeController.forward(from: 0);
    }
  }

  Future<void> _onVerifyOtp() async {
    final l10n = context.l10n;
    final code = _otpController.text.replaceAll(RegExp(r'\D'), '');
    if (code.length != 6) {
      _triggerErrorShake(l10n.authOtpInvalidError);
      return;
    }
    if (code == '000000') {
      _triggerErrorShake(l10n.authOtpWrongCodeError);
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyPhoneOtp(
      verificationId: _verificationId,
      smsCode: code,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (uid) {
        setState(() => _isVerified = true);
        ref.read(currentUserIdStateProvider.notifier).state = uid;
        context.go(AppRoutes.profileSetup);
      },
      failure: (_) {
        _triggerErrorShake(l10n.authOtpWrongCodeError);
      },
    );
  }

  Future<void> _onResendOtp() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendPhoneOtp(
      phoneNumber: widget.args.phoneNumber,
    );
    if (!mounted) return;
    result.when(
      success: (newVerificationId) {
        setState(() => _verificationId = newVerificationId);
        ref.read(otpTimerProvider.notifier).restart();
      },
      failure: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final remainingSeconds = ref.watch(otpTimerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authOtpTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.authOtpSubtitle(widget.args.phoneNumber),
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final dx = math.sin(_shakeController.value * math.pi * 4) *
                            10 *
                            (1.0 - _shakeController.value);
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          _SixDigitBoxesDisplay(
                            code: _otpController.text,
                            hasError: _otpError != null,
                            isVerified: _isVerified,
                            onTap: () => _focusNode.requestFocus(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            key: const Key('otp_code_input_field'),
                            controller: _otpController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: l10n.authOtpCodeLabel,
                              errorText: _otpError,
                              counterText: '',
                            ),
                            onChanged: (val) {
                              setState(() {});
                              if (val.replaceAll(RegExp(r'\D'), '').length == 6) {
                                _onVerifyOtp();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_isVerified) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.authOtpVerifiedSuccess,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: l10n.authVerifyOtpButton,
                      isLoading: _isLoading,
                      enableHaptic: true,
                      onPressed: _onVerifyOtp,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: remainingSeconds == 0 ? _onResendOtp : null,
                        child: Text(
                          remainingSeconds > 0
                              ? l10n.authResendTimer(remainingSeconds)
                              : l10n.authResendNow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SixDigitBoxesDisplay extends StatelessWidget {
  const _SixDigitBoxesDisplay({
    required this.code,
    required this.hasError,
    required this.isVerified,
    required this.onTap,
  });

  final String code;
  final bool hasError;
  final bool isVerified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final clean = code.replaceAll(RegExp(r'\D'), '');

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          final char = index < clean.length ? clean[index] : '';
          final isFocused = index == clean.length;
          final borderColor = hasError
              ? scheme.error
              : isVerified
                  ? AppColors.success
                  : isFocused
                      ? scheme.primary
                      : scheme.outline;

          return Container(
            width: 46,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: borderColor,
                width: (isFocused || hasError || isVerified) ? 2.0 : 1.2,
              ),
            ),
            child: Text(
              char,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }),
      ),
    );
  }
}

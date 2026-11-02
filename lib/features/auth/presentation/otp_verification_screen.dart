import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/auth/data/firebase_auth_repository.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/login_screen.dart';
import 'package:turkiye_kan_agi/features/auth/presentation/otp_timer_notifier.dart';

/// 6 haneli SMS OTP doğrulama ve yeniden gönderme sayacı ekranı.
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

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  late String _verificationId;
  String? _otpError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.args.verificationId;
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onVerifyOtp() async {
    final l10n = context.l10n;
    final code = _otpController.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() {
        _otpError = l10n.authOtpInvalidError;
      });
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
        ref.read(currentUserIdStateProvider.notifier).state = uid;
        context.go(AppRoutes.profileSetup);
      },
      failure: (failure) {
        setState(() {
          _otpError = failure.toLocalizedMessage(l10n);
        });
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
      appBar: AppBar(
        title: Text(l10n.authOtpTitle),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.authOtpSubtitle(widget.args.phoneNumber),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    key: const Key('otp_code_input_field'),
                    controller: _otpController,
                    labelText: l10n.authOtpCodeLabel,
                    hintText: '123456',
                    errorText: _otpError,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: l10n.authVerifyOtpButton,
                    isLoading: _isLoading,
                    onPressed: _onVerifyOtp,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: remainingSeconds == 0 ? _onResendOtp : null,
                      child: Text(
                        remainingSeconds > 0
                            ? l10n.authResendCountdown(remainingSeconds)
                            : l10n.authResendNow,
                      ),
                    ),
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

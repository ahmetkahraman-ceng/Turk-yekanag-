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
import 'package:turkiye_kan_agi/features/auth/domain/turkish_phone_validator.dart';

/// Telefon numarası + OTP ve alternatif Google / Apple giriş ekranı.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneError;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSendOtp() async {
    final l10n = context.l10n;
    final normalized = TurkishPhoneValidator.normalize(_phoneController.text);
    if (normalized == null) {
      setState(() {
        _phoneError = l10n.authPhoneInvalidError;
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _isLoading = true;
    });

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendPhoneOtp(phoneNumber: normalized);

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (verificationId) {
        context.push(
          AppRoutes.otpVerification,
          extra: OtpRouteArgs(
            phoneNumber: normalized,
            verificationId: verificationId,
          ),
        );
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.toLocalizedMessage(l10n))),
        );
      },
    );
  }

  Future<void> _onSocialSignIn({required bool isGoogle}) async {
    final l10n = context.l10n;
    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final result = isGoogle
        ? await repo.signInWithGoogle()
        : await repo.signInWithApple();

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (uid) {
        ref.read(currentUserIdStateProvider.notifier).state = uid;
        context.go(AppRoutes.profileSetup);
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.toLocalizedMessage(l10n))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authLoginTitle),
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
                    l10n.authLoginSubtitle,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    key: const Key('phone_input_field'),
                    controller: _phoneController,
                    labelText: l10n.authPhoneLabel,
                    hintText: l10n.authPhoneHint,
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_android_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: l10n.authSendOtpButton,
                    icon: Icons.sms_outlined,
                    isLoading: _isLoading,
                    onPressed: _onSendOtp,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Text(
                          l10n.authOrDivider,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        AppSpacing.minTouchTarget,
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _onSocialSignIn(isGoogle: true),
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: Text(l10n.authContinueWithGoogle),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        AppSpacing.minTouchTarget,
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _onSocialSignIn(isGoogle: false),
                    icon: const Icon(Icons.apple_rounded, size: 24),
                    label: Text(l10n.authContinueWithApple),
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

/// OTP doğrulama ekranına aktarılan rota parametreleri.
class OtpRouteArgs {
  const OtpRouteArgs({
    required this.phoneNumber,
    required this.verificationId,
  });

  final String phoneNumber;
  final String verificationId;
}

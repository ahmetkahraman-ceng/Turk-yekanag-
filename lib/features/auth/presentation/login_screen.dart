import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/branding/blood_logo.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/auth/data/firebase_auth_repository.dart';
import 'package:turkiye_kan_agi/features/auth/domain/turkish_phone_validator.dart';

/// Türkiye telefon numarası maskeleyici (5XX XXX XX XX).
class TurkishPhoneMaskFormatter extends TextInputFormatter {
  const TurkishPhoneMaskFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.startsWith('90') && digits.length > 10
        ? digits.substring(2)
        : digits.startsWith('0') && digits.length > 10
            ? digits.substring(1)
            : digits;
    final clipped =
        trimmed.length > 10 ? trimmed.substring(0, 10) : trimmed;

    final buffer = StringBuffer();
    for (var i = 0; i < clipped.length; i++) {
      if (i == 3 || i == 6 || i == 8) buffer.write(' ');
      buffer.write(clipped[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Giriş ekranı:
/// Logo, telefon alanı (+90 sabit, 5XX XXX XX XX maskeli), "Kod Gönder",
/// "veya" altında Google ve Apple butonları, alt bilgi Kullanım Şartları/Gizlilik linkleri.
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
      setState(() => _phoneError = l10n.authPhoneInvalidError);
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
        AppSnackbar.show(context, message: failure.toLocalizedMessage(l10n));
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
        AppSnackbar.show(context, message: failure.toLocalizedMessage(l10n));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authLoginTitle)),
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
                    const Center(child: BloodLogo(size: 76)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.authLoginSubtitle,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      key: const Key('phone_input_field'),
                      controller: _phoneController,
                      labelText: l10n.authPhoneLabel,
                      hintText: l10n.authPhoneHint,
                      errorText: _phoneError,
                      prefixText: '+90 ',
                      prefixIcon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: const [TurkishPhoneMaskFormatter()],
                      onFieldSubmitted: (_) => _onSendOtp(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: const Key('send_otp_button'),
                      label: l10n.authSendCodeShort,
                      icon: Icons.sms_outlined,
                      isLoading: _isLoading,
                      enableHaptic: true,
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
                            l10n.authOrSimple,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l10n.authContinueWithGoogle,
                      variant: AppButtonVariant.secondary,
                      icon: Icons.g_mobiledata_rounded,
                      onPressed: _isLoading
                          ? null
                          : () => _onSocialSignIn(isGoogle: true),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.authContinueWithApple,
                      variant: AppButtonVariant.secondary,
                      icon: Icons.apple_rounded,
                      onPressed: _isLoading
                          ? null
                          : () => _onSocialSignIn(isGoogle: false),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      children: [
                        TextButton(
                          onPressed: () => context.push(AppRoutes.termsOfUse),
                          child: Text(l10n.termsOfUseTitle),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.privacyPolicy),
                          child: Text(l10n.privacyPolicyTitle),
                        ),
                      ],
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

/// OTP doğrulama ekranına aktarılan rota parametreleri.
class OtpRouteArgs {
  const OtpRouteArgs({
    required this.phoneNumber,
    required this.verificationId,
  });

  final String phoneNumber;
  final String verificationId;
}

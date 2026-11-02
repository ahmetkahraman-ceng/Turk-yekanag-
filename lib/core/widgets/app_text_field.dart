import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// Erişilebilirlik (Semantics ve min 48dp dokunma alanı) destekli merkezi metin giriş alanı.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.labelText,
    super.key,
    this.controller,
    this.hintText,
    this.errorText,
    this.semanticsLabel,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final String? semanticsLabel;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      enabled: enabled,
      label: semanticsLabel ?? labelText,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}

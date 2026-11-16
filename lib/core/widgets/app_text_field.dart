import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';

/// Erişilebilirlik (Semantics ve min 48dp dokunma alanı) destekli merkezi metin giriş alanı.
/// Etiket, yardım metni, hata, prefix/suffix ve telefon/numara/şifre varyantlarını destekler.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.labelText,
    super.key,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticsLabel,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enablePasswordToggle = false,
    this.enabled = true,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.maxLines = 1,
    this.focusNode,
  });

  const AppTextField.phone({
    required this.labelText,
    super.key,
    this.controller,
    this.hintText = '5XX XXX XX XX',
    this.helperText,
    this.errorText,
    this.semanticsLabel,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.focusNode,
  })  : keyboardType = TextInputType.phone,
        autofillHints = const [AutofillHints.telephoneNumber],
        inputFormatters = null,
        obscureText = false,
        enablePasswordToggle = false,
        prefixIcon = Icons.phone_rounded,
        prefixText = '+90 ',
        suffixIcon = null,
        maxLines = 1;

  const AppTextField.number({
    required this.labelText,
    super.key,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticsLabel,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.focusNode,
  })  : keyboardType = TextInputType.number,
        autofillHints = null,
        inputFormatters = null,
        obscureText = false,
        enablePasswordToggle = false,
        prefixText = null,
        maxLines = 1;

  const AppTextField.password({
    required this.labelText,
    super.key,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticsLabel,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.focusNode,
  })  : keyboardType = TextInputType.visiblePassword,
        autofillHints = const [AutofillHints.password],
        inputFormatters = null,
        obscureText = true,
        enablePasswordToggle = true,
        prefixIcon = Icons.lock_outline_rounded,
        prefixText = null,
        suffixIcon = null,
        maxLines = 1;

  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? semanticsLabel;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enablePasswordToggle;
  final bool enabled;
  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final effectiveSuffix = widget.enablePasswordToggle
        ? IconButton(
            onPressed: () => setState(() => _obscured = !_obscured),
            icon: Icon(
              _obscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          )
        : widget.suffixIcon;

    return Semantics(
      textField: true,
      enabled: widget.enabled,
      label: widget.semanticsLabel ?? widget.labelText,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          obscureText: _obscured,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          maxLines: _obscured ? 1 : widget.maxLines,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixText: widget.prefixText,
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: effectiveSuffix,
          ),
        ),
      ),
    );
  }
}

/// Merkezi arama giriş alanı.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.hintText,
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      labelText: hintText,
      hintText: hintText,
      controller: controller,
      prefixIcon: Icons.search_rounded,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      suffixIcon: controller != null && controller!.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                controller?.clear();
                onClear?.call();
                onChanged?.call('');
              },
              icon: const Icon(Icons.close_rounded),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_chip.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';

/// Talep sahibinin bağışçıya teşekkür mesajı gönderebileceği Bottom Sheet:
/// Hazır mesaj çipleri + serbest kısa metin alanı.
class ThankYouSheet extends StatefulWidget {
  const ThankYouSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return AppBottomSheet.show<String>(
      context: context,
      builder: (_) => const ThankYouSheet(),
    );
  }

  @override
  State<ThankYouSheet> createState() => _ThankYouSheetState();
}

class _ThankYouSheetState extends State<ThankYouSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = [
      l10n.thankYouChip1,
      l10n.thankYouChip2,
      l10n.thankYouChip3,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.thankYouSheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final msg in chips)
                AppChip(
                  label: msg,
                  selected: _controller.text == msg,
                  onSelected: (_) => setState(() => _controller.text = msg),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _controller,
            labelText: l10n.thankYouCustomHint,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.thankYouSendButton,
            icon: Icons.favorite_rounded,
            enableHaptic: true,
            onPressed: () {
              final text = _controller.text.trim().isEmpty
                  ? l10n.thankYouChip1
                  : _controller.text.trim();
              Navigator.of(context).pop(text);
            },
          ),
        ],
      ),
    );
  }
}

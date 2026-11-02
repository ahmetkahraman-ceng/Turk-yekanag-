import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';

/// Yasal doküman türü (Gizlilik Politikası veya Kullanım Şartları).
enum LegalDocumentType {
  privacyPolicy,
  termsOfUse,
}

/// Uygulama içi Gizlilik Politikası ve Kullanım Şartları görüntüleme ekranı.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    required this.documentType,
    super.key,
  });

  final LegalDocumentType documentType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final isPrivacy = documentType == LegalDocumentType.privacyPolicy;
    final title =
        isPrivacy ? l10n.privacyPolicyTitle : l10n.termsOfUseTitle;
    final body = isPrivacy
        ? l10n.privacyPolicyPlaceholderBody
        : l10n.termsOfUsePlaceholderBody;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                body,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

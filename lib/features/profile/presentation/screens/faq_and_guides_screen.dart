import 'package:flutter/material.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';

class _FaqEntry {
  const _FaqEntry({required this.question, required this.answer});
  final String question;
  final String answer;
}

const List<_FaqEntry> _faqItems = [
  _FaqEntry(
    question: 'Türkiye Kan Ağı Kızılay’ın yerine mi geçiyor?',
    answer:
        'Hayır. Türkiye Kan Ağı Kızılay’ı tamamlayıcı bir gönüllü duyuru ve eşleştirme ağıdır. Kan alma işlemi yalnızca yetkili kan merkezlerinde ve hastanelerde yapılır.',
  ),
  _FaqEntry(
    question: 'Telefon numaram herkese açık mı?',
    answer:
        'Hayır. Telefon numaranız yalnızca siz "Yardım Edebilirim" dediğinizde ve talep sahibi onay verdiğinde paylaşılır.',
  ),
  _FaqEntry(
    question: 'Kan bağışı için ücret talep edilebilir mi?',
    answer:
        'Kesinlikle hayır. Para veya menfaat karşılığı kan alım-satımı yasaktır ve bu tür talepler otomatik filtrelenir.',
  ),
];

const List<_FaqEntry> _mythsAndFacts = [
  _FaqEntry(
    question: 'Efsane: Kan vermek kilo aldırır veya zayıflatır.',
    answer:
        'Gerçek: Kan bağışı metabolik kilo değişimine yol açmaz; vücut sıvı dengesini kısa sürede yeniler.',
  ),
  _FaqEntry(
    question: 'Efsane: Kan bağışı alışkanlık yapar, sürekli vermek gerekir.',
    answer:
        'Gerçek: Kan bağışı fizyolojik bağımlılık yapmaz; dilediğiniz zaman uygun aralıklarla bağış yapabilirsiniz.',
  ),
];

/// Aşama 7.6: SSS (genişleyen, aramalı), Efsaneler ve Gerçekler,
/// ve "Kan lazım, ne yapmalıyım?" adım adım büyük rehber.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filtered = _faqItems
        .where(
          (e) =>
              e.question.toLowerCase().contains(_query.toLowerCase()) ||
              e.answer.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.faqTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.profileSectionHelpFaq),
              Tab(text: l10n.mythsAndFactsTab),
            ],
          ),
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  ResponsiveConstrainedBox(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        AppSearchField(
                          controller: _searchCtrl,
                          hintText: l10n.faqTitle,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final item in filtered)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              padding: EdgeInsets.zero,
                              child: ExpansionTile(
                                title: Text(item.question),
                                childrenPadding:
                                    const EdgeInsets.all(AppSpacing.md),
                                children: [Text(item.answer)],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ResponsiveConstrainedBox(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        for (final item in _mythsAndFacts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.question,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(item.answer),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Kan lazım, ne yapmalıyım?" adım adım büyük adımlı rehber ekranı.
class EmergencyGuideScreen extends StatelessWidget {
  const EmergencyGuideScreen({super.key});

  static const List<(String, String)> _steps = [
    (
      '1. Hastane ve Kan Merkezini Doğrulayın',
      'Hastanın yattığı hastane adını, servisi, istenen kan grubunu ve ürün tipini (Tam Kan / Eritrosit / Trombosit) netleştirin.'
    ),
    (
      '2. Uygulamadan Talep Açın',
      'Talepler sekmesindeki "Kan İstiyorum" butonuna dokunarak 4 adımda çağrınızı yayınlayın.'
    ),
    (
      '3. Görsel Kartı Yakınlarınızla Paylaşın',
      'Oluşturulan paylaşım kartını WhatsApp gruplarınızda paylaşarak daha hızlı gönüllüye ulaşın.'
    ),
    (
      '4. Gelen Teklifleri Onaylayın ve Koordine Olun',
      'Yardım teklifi gönderen gönüllüleri onaylayarak güvenli iletişim kurun.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emergencyGuideTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.$1,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  step.$2,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

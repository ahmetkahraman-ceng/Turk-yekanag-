import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/core/widgets/feature_placeholder_view.dart';

/// Bağış sekmesi başlangıç ekranı.
/// Bağış aralıkları koda gömülmez, RemoteConfigService üzerinden okunur.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class DonationScreen extends ConsumerWidget {
  const DonationScreen({
    super.key,
    this.initialState = ScreenViewState.empty,
  });

  final ScreenViewState initialState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
    final remoteConfig = ref.watch(remoteConfigServiceProvider);

    return FeaturePlaceholderView(
      title: l10n.donationTitle,
      emptyTitle: l10n.donationEmptyTitle,
      emptySubtitle: l10n.donationEmptySubtitle,
      icon: Icons.favorite_border_rounded,
      initialState: initialState,
      footerNote: l10n.donationIntervalInfo(
        remoteConfig.wholeBloodIntervalDaysMale,
        remoteConfig.wholeBloodIntervalDaysFemale,
      ),
    );
  }
}

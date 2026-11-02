import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/loading_skeleton.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';

/// Kan Talepleri listesi ekranı:
/// Kan grubu, ürün tipi, il ve aciliyet filtreleri, pull-to-refresh, sayfalama ve skeleton yükleme.
class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  BloodRequestFilter _filter = const BloodRequestFilter();
  List<BloodRequest> _requests = const <BloodRequest>[];
  bool _isLoading = true;
  bool _hasError = false;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final res = await ref.read(bloodRequestRepositoryProvider).fetchRequests(
          filter: _filter,
          limit: _pageSize,
        );
    if (!mounted) return;
    res.when(
      success: (list) => setState(() {
        _requests = list;
        _isLoading = false;
      }),
      failure: (_) => setState(() {
        _isLoading = false;
        _hasError = true;
      }),
    );
  }

  String _urgencyLabel(BuildContext context, RequestUrgency urgency) {
    final l10n = context.l10n;
    return switch (urgency) {
      RequestUrgency.critical => l10n.urgencyCritical,
      RequestUrgency.today => l10n.urgencyToday,
      RequestUrgency.thisWeek => l10n.urgencyThisWeek,
    };
  }

  String _productLabel(BuildContext context, BloodProductType type) {
    final l10n = context.l10n;
    return switch (type) {
      BloodProductType.wholeBlood => l10n.productWholeBlood,
      BloodProductType.erythrocyte => l10n.productErythrocyte,
      BloodProductType.platelet => l10n.productPlatelet,
      BloodProductType.plasma => l10n.productPlasma,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create_request_fab'),
        onPressed: () async {
          await context.push('${AppRoutes.requests}/create');
          await _fetchRequests();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.requestCreateTitle),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                for (final bt in [BloodType.aPos, BloodType.oNeg, BloodType.bPos])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      key: Key('filter_blood_${bt.code}'),
                      label: Text(bt.code),
                      selected: _filter.bloodType == bt,
                      onSelected: (selected) {
                        setState(() {
                          _filter = selected
                              ? _filter.copyWith(bloodType: bt)
                              : _filter.copyWith(clearBloodType: true);
                        });
                        _fetchRequests();
                      },
                    ),
                  ),
                FilterChip(
                  key: const Key('filter_urgency_critical'),
                  label: Text(l10n.urgencyCritical),
                  selected: _filter.urgency == RequestUrgency.critical,
                  onSelected: (selected) {
                    setState(() {
                      _filter = selected
                          ? _filter.copyWith(urgency: RequestUrgency.critical)
                          : _filter.copyWith(clearUrgency: true);
                    });
                    _fetchRequests();
                  },
                ),
                if (_filter.hasAnyFilter) ...[
                  const SizedBox(width: AppSpacing.xs),
                  TextButton(
                    key: const Key('clear_filters_button'),
                    onPressed: () {
                      setState(() => _filter = const BloodRequestFilter());
                      _fetchRequests();
                    },
                    child: Text(l10n.requestFilterClear),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingSkeleton()
                : _hasError
                    ? ErrorState(
                        title: l10n.commonErrorTitle,
                        message: l10n.commonErrorMessage,
                        onRetry: _fetchRequests,
                      )
                    : _requests.isEmpty
                        ? EmptyState(
                            icon: Icons.bloodtype_outlined,
                            title: l10n.requestsEmptyTitle,
                            subtitle: l10n.requestsEmptySubtitle,
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchRequests,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: _requests.length + 1,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                if (index == _requests.length) {
                                  return Center(
                                    child: TextButton(
                                      key: const Key('load_more_requests_button'),
                                      onPressed: () {
                                        setState(() => _pageSize += 10);
                                        _fetchRequests();
                                      },
                                      child: Text(l10n.requestLoadMore),
                                    ),
                                  );
                                }
                                final req = _requests[index];
                                return Card(
                                  child: ListTile(
                                    key: Key('request_card_${req.id}'),
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      foregroundColor: Colors.white,
                                      child: Text(
                                        req.bloodType.code,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${req.hospital.name} (${req.hospital.district}/${req.hospital.province})',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    subtitle: Text(
                                      '${_productLabel(context, req.productType)} • ${l10n.requestUnitsValue(req.unitsNeeded)} • ${_urgencyLabel(context, req.urgency)}',
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                    onTap: () => context.push(
                                      '${AppRoutes.requests}/${req.id}',
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

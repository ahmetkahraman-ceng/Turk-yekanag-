import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_chip.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/countdown_ring.dart';
import 'package:turkiye_kan_agi/core/widgets/empty_state.dart';
import 'package:turkiye_kan_agi/core/widgets/error_state.dart';
import 'package:turkiye_kan_agi/core/widgets/skeleton_widgets.dart';
import 'package:turkiye_kan_agi/core/widgets/tiles_and_selection_sheet.dart';
import 'package:turkiye_kan_agi/features/donation/domain/donor_status_snapshot.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/turkey_location_data.dart';
import 'package:turkiye_kan_agi/features/requests/data/firestore_blood_request_repository.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_request_filter.dart';
import 'package:turkiye_kan_agi/features/requests/domain/request_urgency.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/widgets/request_card.dart';
import 'package:turkiye_kan_agi/features/requests/presentation/widgets/request_filter_sheet.dart';

/// Talepler ekranı (CustomScrollView + slivers):
/// - Küçülen SliverAppBar (il/ilçe seçici, sağda filtre ikonu ve uygulanan filtre sayısı rozeti)
/// - Bağış durumu kartı ("Bağışa uygunsun" yeşil veya "Sonraki bağışına X gün var" küçük CountdownRing, dokununca Bağış sekmesine)
/// - Yatay filtre çipleri (Benim kan grubum, Tümü, ACİL, Bugün, Yakınımda)
/// - RequestCard listesi, pull-to-refresh, sonsuz kaydırma, skeleton, empty ve error
/// - Sağ altta genişletilmiş FAB "Kan İstiyorum" (kaydırırken sadece ikona küçülür).
class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  final ScrollController _scrollController = ScrollController();
  BloodRequestFilter _filter = const BloodRequestFilter();
  Set<BloodType> _multiBloodTypes = <BloodType>{};
  double? _maxDistanceKm;
  List<BloodRequest> _requests = const <BloodRequest>[];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFabExtended = true;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchRequests();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isFabExtended) {
      setState(() => _isFabExtended = false);
    } else if (direction == ScrollDirection.forward && !_isFabExtended) {
      setState(() => _isFabExtended = true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_filter.bloodType != null || _multiBloodTypes.isNotEmpty) count++;
    if (_filter.productType != null) count++;
    if (_filter.urgency != null) count++;
    if (_filter.province != null) count++;
    if (_maxDistanceKm != null) count++;
    return count;
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
      success: (list) {
        final filtered = _multiBloodTypes.length > 1
            ? list.where((r) => _multiBloodTypes.contains(r.bloodType)).toList()
            : list;
        setState(() {
          _requests = filtered;
          _isLoading = false;
        });
      },
      failure: (_) => setState(() {
        _isLoading = false;
        _hasError = true;
      }),
    );
  }

  Future<void> _openFilterSheet() async {
    final res = await RequestFilterSheet.show(
      context: context,
      initialFilter: _filter,
      initialBloodTypes: _multiBloodTypes,
      initialDistanceKm: _maxDistanceKm,
    );
    if (res != null) {
      setState(() {
        _filter = res.filter;
        _multiBloodTypes = res.selectedBloodTypes;
        _maxDistanceKm = res.maxDistanceKm;
      });
      await _fetchRequests();
    }
  }

  Future<void> _pickCity() async {
    final provinces =
        ref.read(turkeyProvincesProvider).valueOrNull ?? const <TurkeyProvince>[];
    if (provinces.isEmpty) return;
    final l10n = context.l10n;
    final selected = await SelectionSheet.show<String>(
      context: context,
      title: l10n.wizardProvinceLabel,
      searchHint: l10n.wizardSearchHint,
      items: provinces.map((p) => p.name).toList(),
      labelBuilder: (s) => s,
      selectedItem: _filter.province,
    );
    if (selected != null) {
      setState(() => _filter = _filter.copyWith(province: selected));
      await _fetchRequests();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filter = const BloodRequestFilter();
      _multiBloodTypes.clear();
      _maxDistanceKm = null;
    });
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filterCount = _activeFilterCount;
    final donorStatus = ref.watch(currentDonorStatusProvider).valueOrNull;
    final userBloodType = donorStatus?.bloodType ?? BloodType.aPos;
    final remainingDays = donorStatus?.remainingDays ?? 24;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create_request_fab'),
        heroTag: 'requests_create_fab_hero',
        isExtended: _isFabExtended,
        onPressed: () async {
          await context.push('${AppRoutes.requests}/create');
          await _fetchRequests();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.actionWantBlood),
      ),
      body: ResponsiveConstrainedBox(
        child: RefreshIndicator(
          onRefresh: _fetchRequests,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                title: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  onTap: _pickCity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_filter.province ?? l10n.requestsTitle),
                        const SizedBox(width: AppSpacing.xxs),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    key: const Key('open_filter_sheet_button'),
                    tooltip: l10n.requestFilterAll,
                    onPressed: _openFilterSheet,
                    icon: Badge(
                      isLabelVisible: filterCount > 0,
                      label: Text('$filterCount'),
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: _DonorQuickStatusBanner(
                    remainingDays: remainingDays,
                    onTap: () => context.go(AppRoutes.donation),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _HorizontalQuickFilterBar(
                  filter: _filter,
                  userBloodType: userBloodType,
                  hasAnyFilter: filterCount > 0,
                  onFilterChanged: (updated) {
                    setState(() => _filter = updated);
                    _fetchRequests();
                  },
                  onClear: _clearAllFilters,
                ),
              ),
              if (_isLoading)
                const SliverToBoxAdapter(child: SkeletonList(itemCount: 4))
              else if (_hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    title: l10n.commonErrorTitle,
                    message: l10n.commonErrorMessage,
                    onRetry: _fetchRequests,
                  ),
                )
              else if (_requests.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: EmptyState(
                          icon: Icons.favorite_outline_rounded,
                          title: l10n.requestsNoOpenNearYouTitle,
                          subtitle: l10n.requestsNoOpenNearYouSubtitle,
                        ),
                      ),
                      if (filterCount > 0)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: AppButton(
                            key: const Key('empty_clear_filters_button'),
                            label: l10n.requestFilterClear,
                            variant: AppButtonVariant.secondary,
                            isExpanded: false,
                            onPressed: _clearAllFilters,
                          ),
                        ),
                    ],
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList.separated(
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
                      return RequestCard(
                        request: req,
                        userBloodType: userBloodType,
                        distanceKm: 1.8 + (index % 7) * 1.3,
                        onTap: () => context.push(
                          '${AppRoutes.requests}/${req.id}',
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonorQuickStatusBanner extends StatelessWidget {
  const _DonorQuickStatusBanner({
    required this.remainingDays,
    required this.onTap,
  });

  /// 0 veya negatifse kullanıcı bağışa uygundur.
  final int remainingDays;
  final VoidCallback onTap;

  // Görsel ilerleme için referans aralık; tıbbi karar için kullanılmaz.
  static const int _referenceIntervalDays = 90;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEligible = remainingDays <= 0;
    final progress = isEligible
        ? 1.0
        : (1 - remainingDays / _referenceIntervalDays).clamp(0.05, 0.95);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          CountdownRing(
            progress: progress,
            centerText: isEligible ? '✓' : '$remainingDays',
            size: 48,
            strokeWidth: 5,
            isEligible: isEligible,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isEligible
                  ? l10n.donorStatusEligibleCard
                  : l10n.donorStatusWaitingCard(remainingDays),
              style: theme.textTheme.titleSmall?.copyWith(
                color: isEligible ? AppColors.success : null,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _HorizontalQuickFilterBar extends StatelessWidget {
  const _HorizontalQuickFilterBar({
    required this.filter,
    required this.userBloodType,
    required this.hasAnyFilter,
    required this.onFilterChanged,
    required this.onClear,
  });

  final BloodRequestFilter filter;
  final BloodType userBloodType;
  final bool hasAnyFilter;
  final ValueChanged<BloodRequestFilter> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final effectiveMyBlood =
        userBloodType == BloodType.unknown ? BloodType.aPos : userBloodType;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AppChip(
            label: l10n.requestFilterAll,
            selected: !hasAnyFilter,
            onSelected: (_) => onClear(),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppChip(
            key: const Key('filter_my_blood_chip'),
            label: '${l10n.filterMyBloodGroup} (${effectiveMyBlood.code})',
            selected: filter.bloodType == effectiveMyBlood,
            onSelected: (sel) => onFilterChanged(
              sel
                  ? filter.copyWith(bloodType: effectiveMyBlood)
                  : filter.copyWith(clearBloodType: true),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          for (final bt in [BloodType.aPos, BloodType.oNeg, BloodType.bPos])
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: FilterChip(
                key: Key('filter_blood_${bt.code}'),
                label: Text(bt.code),
                selected: filter.bloodType == bt,
                onSelected: (sel) => onFilterChanged(
                  sel
                      ? filter.copyWith(bloodType: bt)
                      : filter.copyWith(clearBloodType: true),
                ),
              ),
            ),
          FilterChip(
            key: const Key('filter_urgency_critical'),
            label: Text(l10n.urgencyCriticalShort),
            selected: filter.urgency == RequestUrgency.critical,
            onSelected: (sel) => onFilterChanged(
              sel
                  ? filter.copyWith(urgency: RequestUrgency.critical)
                  : filter.copyWith(clearUrgency: true),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppChip(
            label: l10n.urgencyTodayShort,
            selected: filter.urgency == RequestUrgency.today,
            onSelected: (sel) => onFilterChanged(
              sel
                  ? filter.copyWith(urgency: RequestUrgency.today)
                  : filter.copyWith(clearUrgency: true),
            ),
          ),
          if (hasAnyFilter) ...[
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              key: const Key('clear_filters_button'),
              onPressed: onClear,
              child: Text(l10n.requestFilterClear),
            ),
          ],
        ],
      ),
    );
  }
}

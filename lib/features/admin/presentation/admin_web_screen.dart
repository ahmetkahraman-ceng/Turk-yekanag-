import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/mock/mock_data.dart';
import 'package:turkiye_kan_agi/core/theme/app_colors.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/section_header.dart';
import 'package:turkiye_kan_agi/features/admin/presentation/widgets/admin_charts.dart';

class _ReportQueueItem {
  const _ReportQueueItem({
    required this.id,
    required this.targetSummary,
    required this.reasonTag,
    required this.reporterAlias,
    this.status = 'pending',
  });

  final String id;
  final String targetSummary;
  final String reasonTag;
  final String reporterAlias;
  final String status;

  _ReportQueueItem copyWith({String? status}) {
    return _ReportQueueItem(
      id: id,
      targetSummary: targetSummary,
      reasonTag: reasonTag,
      reporterAlias: reporterAlias,
      status: status ?? this.status,
    );
  }
}

/// Aşama 8: Admin Web Paneli UI (`/admin`, Flutter Web uyumlu, masaüstü öncelikli, responsive).
class AdminWebScreen extends StatefulWidget {
  const AdminWebScreen({super.key, this.initialAuthenticated = false});

  final bool initialAuthenticated;

  @override
  State<AdminWebScreen> createState() => _AdminWebScreenState();
}

class _AdminWebScreenState extends State<AdminWebScreen> {
  late bool _isAuthenticated = widget.initialAuthenticated;
  int _selectedNavIndex = 0;
  final _emailCtrl = TextEditingController(text: 'admin@kanagi.org.tr');
  final _passwordCtrl = TextEditingController();
  String? _selectedDetailTitle;
  String? _selectedDetailBody;

  final List<_ReportQueueItem> _reports = [
    const _ReportQueueItem(
      id: 'rep-101',
      targetSummary: 'Talep #req-seed-1 — Ankara Bilkent Şehir Hastanesi',
      reasonTag: 'Yanlış Hastane Bilgisi',
      reporterAlias: 'Gönüllü #42',
    ),
    const _ReportQueueItem(
      id: 'rep-102',
      targetSummary: 'Kullanıcı @k_gonullu34 — Uygunsuz İletişim',
      reasonTag: 'Spam / Kötüye Kullanım',
      reporterAlias: 'Gönüllü #18',
    ),
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReportAction(
    _ReportQueueItem item,
    String newStatus,
    String actionLabel,
  ) async {
    final confirmed = await ConfirmSheet.show(
      context: context,
      icon: Icons.admin_panel_settings_rounded,
      title: '$actionLabel: ${item.id}',
      message: item.targetSummary,
      confirmLabel: actionLabel,
      isDanger: newStatus == 'restricted',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      final idx = _reports.indexWhere((r) => r.id == item.id);
      if (idx != -1) {
        _reports[idx] = _reports[idx].copyWith(status: newStatus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminTitle)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.adminLoginTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      key: const Key('admin_email_field'),
                      controller: _emailCtrl,
                      labelText: 'E-posta (Role: SuperAdmin)',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      key: const Key('admin_password_field'),
                      controller: _passwordCtrl,
                      obscureText: true,
                      enablePasswordToggle: true,
                      labelText: 'Parola',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: const Key('admin_login_submit_button'),
                      label: l10n.adminLoginTitle,
                      onPressed: () => setState(() => _isAuthenticated = true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final navLabels = [
      (Icons.dashboard_rounded, l10n.adminNavDashboard),
      (Icons.flag_rounded, l10n.adminNavReports),
      (Icons.bloodtype_rounded, l10n.adminNavRequests),
      (Icons.people_alt_rounded, l10n.adminNavUsers),
      (Icons.apartment_rounded, l10n.adminNavInstitutions),
      (Icons.campaign_rounded, l10n.adminNavCampaigns),
      (Icons.receipt_long_rounded, l10n.adminNavAuditLog),
      (Icons.settings_rounded, l10n.adminNavSettings),
    ];

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyA): () {
          if (_reports.isNotEmpty) {
            _handleReportAction(
              _reports.first,
              'approved',
              l10n.adminApproveAction,
            );
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyR): () {
          if (_reports.isNotEmpty) {
            _handleReportAction(
              _reports.first,
              'rejected',
              l10n.adminRejectAction,
            );
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.adminTitle)),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedNavIndex,
                onDestinationSelected: (idx) =>
                    setState(() => _selectedNavIndex = idx),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final item in navLabels)
                    NavigationRailDestination(
                      icon: Icon(item.$1),
                      label: Text(item.$2),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 3,
                child: _buildSelectedSection(context),
              ),
              if (_selectedDetailTitle != null) ...[
                const VerticalDivider(width: 1),
                SizedBox(
                  width: 280,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDetailTitle!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedDetailTitle = null),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(_selectedDetailBody ?? ''),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSection(BuildContext context) {
    final l10n = context.l10n;
    if (_selectedNavIndex == 1) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SectionHeader(title: l10n.adminNavReports),
          for (final item in _reports)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => setState(() {
                  _selectedDetailTitle = item.id;
                  _selectedDetailBody =
                      '${item.targetSummary}\nEtiket: ${item.reasonTag}\nDurum: ${item.status}';
                }),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.targetSummary,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Chip(label: Text(item.reasonTag)),
                      ],
                    ),
                    Text('${item.reporterAlias} • Durum: ${item.status}'),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        AppButton(
                          key: Key('admin_approve_${item.id}'),
                          label: l10n.adminApproveAction,
                          isExpanded: false,
                          onPressed: () => _handleReportAction(
                            item,
                            'approved',
                            l10n.adminApproveAction,
                          ),
                        ),
                        AppButton(
                          key: Key('admin_reject_${item.id}'),
                          label: l10n.adminRejectAction,
                          variant: AppButtonVariant.secondary,
                          isExpanded: false,
                          onPressed: () => _handleReportAction(
                            item,
                            'rejected',
                            l10n.adminRejectAction,
                          ),
                        ),
                        AppButton(
                          key: Key('admin_restrict_${item.id}'),
                          label: l10n.adminRestrictAction,
                          variant: AppButtonVariant.danger,
                          isExpanded: false,
                          onPressed: () => _handleReportAction(
                            item,
                            'restricted',
                            l10n.adminRestrictAction,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    final requests = MockData.requests.take(8).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _AdminStatCard(
              title: l10n.adminStatOpenRequests,
              value: '32',
              color: AppColors.primary,
            ),
            _AdminStatCard(
              title: l10n.adminStatFulfillmentRate,
              value: '%78',
              color: AppColors.success,
            ),
            _AdminStatCard(
              title: l10n.adminStatPendingReports,
              value: '${_reports.where((r) => r.status == 'pending').length}',
              color: AppColors.warning,
            ),
            _AdminStatCard(
              title: l10n.adminStatNewUsers,
              value: '1.240',
              color: AppColors.info,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const AdminChartsRow(),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: l10n.adminNavRequests),
        AppCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Kan')),
                DataColumn(label: Text('Hastane')),
                DataColumn(label: Text('İl / İlçe')),
              ],
              rows: [
                for (final req in requests)
                  DataRow(
                    onSelectChanged: (_) => setState(() {
                      _selectedDetailTitle = req.id;
                      _selectedDetailBody =
                          '${req.hospital.name}\n${req.hospital.district} / ${req.hospital.province}\nKan: ${req.bloodType.code}';
                    }),
                    cells: [
                      DataCell(Text(req.id)),
                      DataCell(Text(req.bloodType.code)),
                      DataCell(Text(req.hospital.name)),
                      DataCell(
                        Text('${req.hospital.province} / ${req.hospital.district}'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

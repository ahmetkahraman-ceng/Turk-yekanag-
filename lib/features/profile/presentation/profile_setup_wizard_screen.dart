import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/location_service.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_button.dart';
import 'package:turkiye_kan_agi/core/widgets/app_card.dart';
import 'package:turkiye_kan_agi/core/widgets/app_overlays.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/async_value_view.dart';
import 'package:turkiye_kan_agi/core/widgets/blood_type_badge.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/step_and_progress.dart';
import 'package:turkiye_kan_agi/core/widgets/tiles_and_selection_sheet.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/turkey_location_data.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/widgets/profile_wizard_dialogs.dart';

enum _WizardStage { form, locationPermission, celebration }

/// Profil oluşturma ve düzenleme sihirbazı (4 adım: StepIndicator, Ad Soyad,
/// 8 Kan Grubu kartı + Bilmiyorum + bilgi sheet'i, Doğum tarihi/Cinsiyet/Kilo,
/// İl/İlçe SelectionSheet + Gerçek GPS Konumu; sonunda Konum izni ve Hazırsın kutlaması).
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
class ProfileSetupWizardScreen extends ConsumerStatefulWidget {
  const ProfileSetupWizardScreen({super.key});

  @override
  ConsumerState<ProfileSetupWizardScreen> createState() =>
      _ProfileSetupWizardScreenState();
}

class _ProfileSetupWizardScreenState
    extends ConsumerState<ProfileSetupWizardScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(
    text: '70',
  );

  int _currentStep = 0;
  _WizardStage _stage = _WizardStage.form;
  bool _useNickname = false;
  DateTime _birthDate = DateTime(1995, 6, 15);
  UserGender _gender = UserGender.unspecified;
  BloodType _bloodType = BloodType.aPos;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfileIfCompleted();
  }

  Future<void> _loadExistingProfileIfCompleted() async {
    final gpsLoc = LocationService.isFlutterTest
        ? null
        : ref.read(userLocationProvider).valueOrNull;
    final isCompleted = ref.read(profileCompletedStateProvider);
    if (!isCompleted) {
      if (gpsLoc != null) {
        setState(() {
          _selectedProvince = gpsLoc.province;
          _selectedDistrict = gpsLoc.district;
        });
      }
      return;
    }
    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final repo = ref.read(profileRepositoryProvider);
    final pubRes = await repo.getPublicProfile(uid);
    final senRes = await repo.getSensitiveProfile(uid);
    if (!mounted) return;
    pubRes.when(
      success: (pub) {
        if (pub != null) {
          setState(() {
            _useNickname = pub.useNickname;
            _selectedProvince = gpsLoc?.province ??
                (pub.province.isNotEmpty ? pub.province : null);
            _selectedDistrict = gpsLoc?.district ??
                (pub.district.isNotEmpty ? pub.district : null);
          });
        }
      },
      failure: (_) {},
    );
    senRes.when(
      success: (sen) {
        if (sen != null) {
          setState(() {
            if (_fullNameController.text.isEmpty) {
              _fullNameController.text = sen.fullName;
            }
            if (sen.nickname != null && _nicknameController.text.isEmpty) {
              _nicknameController.text = sen.nickname!;
            }
            _weightController.text = sen.weightKg.toString();
            _birthDate = sen.birthDate;
            _gender = sen.gender;
            _bloodType = sen.bloodType;
          });
        }
      },
      failure: (_) {},
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _useCurrentGpsLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _currentStep = 3;
    });
    final loc =
        await ref.read(userLocationProvider.notifier).refreshWithPermission();
    if (!mounted) return;
    setState(() {
      _isFetchingLocation = false;
      if (loc != null) {
        _selectedProvince = loc.province;
        _selectedDistrict = loc.district;
        _errorMessage = null;
      }
    });
    if (loc != null) {
      AppSnackbar.show(
        context,
        message: '${loc.formattedArea} (${loc.formattedCoordinates})',
      );
    } else {
      AppSnackbar.show(
        context,
        message: context.l10n.mapNoLocationTitle,
      );
    }
  }

  Future<void> _selectProvince(List<TurkeyProvince> provinces) async {
    final l10n = context.l10n;
    final selected = await SelectionSheet.show<String>(
      context: context,
      title: l10n.wizardProvinceLabel,
      searchHint: l10n.wizardSearchHint,
      items: provinces.map((p) => p.name).toList(growable: false),
      labelBuilder: (s) => s,
      selectedItem: _selectedProvince,
    );
    if (selected != null && selected != _selectedProvince) {
      setState(() {
        _selectedProvince = selected;
        _selectedDistrict = null;
        _currentStep = 3;
      });
    }
  }

  Future<void> _selectDistrict(List<TurkeyProvince> provinces) async {
    if (_selectedProvince == null) return;
    final l10n = context.l10n;
    final provinceObj =
        provinces.where((p) => p.name == _selectedProvince).firstOrNull;
    if (provinceObj == null) return;
    final selected = await SelectionSheet.show<String>(
      context: context,
      title: l10n.wizardDistrictLabel,
      searchHint: l10n.wizardSearchHint,
      items: provinceObj.districts,
      labelBuilder: (s) => s,
      selectedItem: _selectedDistrict,
    );
    if (selected != null) {
      setState(() {
        _selectedDistrict = selected;
        _currentStep = 3;
      });
    }
  }

  void _showUnknownBloodInfoSheet() {
    final l10n = context.l10n;
    AppBottomSheet.show<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.unknownBloodGuideTitle,
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.unknownBloodGuideIntro),
            const SizedBox(height: AppSpacing.sm),
            Text('• ${l10n.unknownBloodGuideStep1Title}'),
            Text('• ${l10n.unknownBloodGuideStep2Title}'),
            Text('• ${l10n.unknownBloodGuideStep3Title}'),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.commonClose,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSaveProfile() async {
    final l10n = context.l10n;
    // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    final fullName = _fullNameController.text.trim();

    if (fullName.isEmpty) {
      setState(() {
        _currentStep = 0;
        _errorMessage = l10n.wizardFullNameRequiredError;
      });
      return;
    }

    final age = DateTime.now().year - _birthDate.year;
    if (age < remoteConfig.minDonorAge || age > remoteConfig.maxDonorAge) {
      setState(() {
        _currentStep = 2;
        _errorMessage = l10n.wizardAgeValidationError(
          remoteConfig.minDonorAge,
          remoteConfig.maxDonorAge,
        );
      });
      return;
    }

    final weight = int.tryParse(_weightController.text.trim()) ?? 0;
    if (weight < remoteConfig.minDonorWeightKg) {
      setState(() {
        _currentStep = 2;
        _errorMessage = l10n.wizardWeightValidationError(
          remoteConfig.minDonorWeightKg,
        );
      });
      return;
    }

    if (_selectedProvince == null || _selectedDistrict == null) {
      setState(() => _isFetchingLocation = true);
      final loc =
          await ref.read(userLocationProvider.notifier).refreshWithPermission();
      if (!mounted) return;
      setState(() => _isFetchingLocation = false);
      if (loc != null) {
        _selectedProvince = loc.province;
        _selectedDistrict = loc.district;
      } else {
        setState(() {
          _currentStep = 3;
          _errorMessage = l10n.wizardLocationRequiredError;
        });
        return;
      }
    }

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    final uid = ref.read(currentUserIdStateProvider) ?? 'local-user';
    final nickname = _nicknameController.text.trim();
    final displayName =
        (_useNickname && nickname.isNotEmpty) ? nickname : fullName;
    final now = DateTime.now().toUtc();

    final publicProfile = UserPublicProfile(
      uid: uid,
      displayName: displayName,
      useNickname: _useNickname,
      province: _selectedProvince!,
      district: _selectedDistrict!,
      isAvailableToDonate: true,
      updatedAt: now,
    );

    final sensitiveProfile = UserSensitiveProfile(
      fullName: fullName,
      nickname: nickname.isEmpty ? null : nickname,
      phoneNumber: '+90 532 ••• •• 48',
      birthDate: _birthDate,
      gender: _gender,
      weightKg: weight,
      bloodType: _bloodType,
      updatedAt: now,
    );

    final consentRecord = ref.read(kvkkConsentProvider);
    await ref.read(profileRepositoryProvider).saveFullProfile(
          publicProfile: publicProfile,
          sensitiveProfile: sensitiveProfile,
          consentRecord: consentRecord,
        );
    ref.read(profileRevisionProvider.notifier).state++;

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _stage = _WizardStage.locationPermission;
    });
  }

  void _finishWizard() {
    ref.read(profileCompletedStateProvider.notifier).state = true;
    context.go(AppRoutes.requests);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provincesAsync = ref.watch(turkeyProvincesProvider);
    final provinces = provincesAsync.valueOrNull ?? const <TurkeyProvince>[];

    if (_stage == _WizardStage.locationPermission) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.wizardTitle)),
        body: ResponsiveConstrainedBox(
          child: LocationPermissionExplainerView(
            onAllowLocation: () async {
              final loc = await ref
                  .read(userLocationProvider.notifier)
                  .refreshWithPermission();
              if (!context.mounted) return;
              if (loc != null) {
                AppSnackbar.show(
                  context,
                  message: '${loc.formattedArea} (${loc.formattedCoordinates})',
                );
              }
              setState(() => _stage = _WizardStage.celebration);
            },
            onSkipLocation: () =>
                setState(() => _stage = _WizardStage.celebration),
          ),
        ),
      );
    }

    if (_stage == _WizardStage.celebration) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.wizardTitle)),
        body: ResponsiveConstrainedBox(
          child: ProfileReadyCelebrationView(onFinish: _finishWizard),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wizardTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          ResponsiveConstrainedBox(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: StepIndicator(
              totalSteps: 4,
              currentStep: _currentStep,
              labels: [
                l10n.wizardStep1Title,
                l10n.wizardStep2Title,
                l10n.wizardStep3Title,
                l10n.wizardStep4Title,
              ],
            ),
          ),
          Expanded(
            child: ResponsiveConstrainedBox(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(l10n.wizardStep1Title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    key: const Key('wizard_full_name_field'),
                    controller: _fullNameController,
                    labelText: l10n.wizardFullNameLabel,
                    prefixIcon: Icons.person_outline_rounded,
                    onChanged: (_) => setState(() => _currentStep = 0),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchTile(
                    title: l10n.wizardUseNicknameSwitch,
                    value: _useNickname,
                    onChanged: (val) => setState(() => _useNickname = val),
                  ),
                  if (_useNickname) ...[
                    const SizedBox(height: AppSpacing.xs),
                    AppTextField(
                      key: const Key('wizard_nickname_field'),
                      controller: _nicknameController,
                      labelText: l10n.wizardNicknameLabel,
                      prefixIcon: Icons.badge_outlined,
                    ),
                  ],
                  const Divider(height: AppSpacing.xl),
                  Text(l10n.wizardStep2Title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.xs,
                    crossAxisSpacing: AppSpacing.xs,
                    children: [
                      for (final type in BloodType.knownValues)
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          borderColor: _bloodType == type
                              ? theme.colorScheme.primary
                              : null,
                          onTap: () => setState(() {
                            _bloodType = type;
                            _currentStep = 1;
                          }),
                          child: Center(
                            child: BloodTypeBadge(
                              bloodType: type,
                              size: BloodBadgeSize.s,
                              isSelected: _bloodType == type,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ChoiceChip(
                        key: const Key('blood_type_unknown_chip'),
                        label: Text(l10n.wizardBloodTypeUnknownOption),
                        selected: _bloodType == BloodType.unknown,
                        onSelected: (_) => setState(() {
                          _bloodType = BloodType.unknown;
                          _currentStep = 1;
                        }),
                      ),
                      TextButton.icon(
                        onPressed: _showUnknownBloodInfoSheet,
                        icon: const Icon(Icons.help_outline_rounded),
                        label: Text(l10n.wizardBloodTypeHowToLearnLink),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  Text(l10n.wizardStep3Title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    key: const Key('wizard_birth_date_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(l10n.wizardBirthDateLabel),
                    subtitle: Text(
                      '${_birthDate.day}.${_birthDate.month}.${_birthDate.year}',
                    ),
                    trailing: TextButton(
                      onPressed: _selectBirthDate,
                      child: Text(l10n.wizardBirthDateSelectButton),
                    ),
                  ),
                  DropdownButtonFormField<UserGender>(
                    initialValue: _gender,
                    decoration: InputDecoration(
                      labelText: l10n.wizardGenderLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: UserGender.male,
                        child: Text(l10n.wizardGenderMale),
                      ),
                      DropdownMenuItem(
                        value: UserGender.female,
                        child: Text(l10n.wizardGenderFemale),
                      ),
                      DropdownMenuItem(
                        value: UserGender.unspecified,
                        child: Text(l10n.wizardGenderUnspecified),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _gender = val;
                          _currentStep = 2;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.number(
                    key: const Key('wizard_weight_field'),
                    controller: _weightController,
                    labelText: l10n.wizardWeightLabel,
                    prefixIcon: Icons.monitor_weight_outlined,
                    onChanged: (_) => setState(() => _currentStep = 2),
                  ),
                  const Divider(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.wizardStep4Title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      TextButton.icon(
                        key: const Key('wizard_use_gps_location_button'),
                        onPressed:
                            _isFetchingLocation ? null : _useCurrentGpsLocation,
                        icon: _isFetchingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, size: 18),
                        label: Text(l10n.locationPermissionAllowButton),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      key: const Key('select_province_tile'),
                      title: Text(_selectedProvince ?? l10n.wizardProvinceLabel),
                      trailing: const Icon(Icons.search_rounded),
                      onTap: () => _selectProvince(provinces),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      key: const Key('select_district_tile'),
                      enabled: _selectedProvince != null,
                      title: Text(_selectedDistrict ?? l10n.wizardDistrictLabel),
                      trailing: const Icon(Icons.search_rounded),
                      onTap: () => _selectDistrict(provinces),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: ResponsiveConstrainedBox(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                key: const Key('wizard_complete_button'),
                label: l10n.wizardCompleteButton,
                isLoading: _isSaving,
                enableHaptic: true,
                onPressed: _onSaveProfile,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

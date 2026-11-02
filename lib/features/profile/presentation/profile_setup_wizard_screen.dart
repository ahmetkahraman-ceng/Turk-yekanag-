import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turkiye_kan_agi/core/l10n/l10n_extension.dart';
import 'package:turkiye_kan_agi/core/router/app_routes.dart';
import 'package:turkiye_kan_agi/core/router/auth_guard_provider.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';
import 'package:turkiye_kan_agi/core/theme/app_spacing.dart';
import 'package:turkiye_kan_agi/core/widgets/app_text_field.dart';
import 'package:turkiye_kan_agi/core/widgets/offline_banner.dart';
import 'package:turkiye_kan_agi/core/widgets/primary_button.dart';
import 'package:turkiye_kan_agi/features/onboarding/presentation/onboarding_state_provider.dart';
import 'package:turkiye_kan_agi/features/profile/data/firestore_profile_repository.dart';
import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/profile/domain/turkey_location_data.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_public_profile.dart';
import 'package:turkiye_kan_agi/features/profile/domain/user_sensitive_profile.dart';
import 'package:turkiye_kan_agi/features/profile/presentation/province_district_picker_dialog.dart';

/// Profil oluşturma ve düzenleme sihirbazı (Ad, Takma Ad, Doğum Tarihi, Cinsiyet, Kilo, Kan Grubu, 81 İl/İlçe).
/// Tıbbi uygunluk sınırları (yaş, kilo) Remote Config üzerinden okunur.
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

  bool _useNickname = false;
  DateTime _birthDate = DateTime(1995, 6, 15);
  UserGender _gender = UserGender.unspecified;
  BloodType _bloodType = BloodType.aPos;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _errorMessage;
  bool _isSaving = false;

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

  Future<void> _selectProvince(List<TurkeyProvince> provinces) async {
    final selected = await SearchableStringPickerDialog.show(
      context,
      title: context.l10n.wizardProvinceLabel,
      items: provinces.map((p) => p.name).toList(growable: false),
    );
    if (selected != null && selected != _selectedProvince) {
      setState(() {
        _selectedProvince = selected;
        _selectedDistrict = null;
      });
    }
  }

  Future<void> _selectDistrict(List<TurkeyProvince> provinces) async {
    if (_selectedProvince == null) return;
    final provinceObj = provinces
        .where((p) => p.name == _selectedProvince)
        .firstOrNull;
    if (provinceObj == null) return;
    final selected = await SearchableStringPickerDialog.show(
      context,
      title: context.l10n.wizardDistrictLabel,
      items: provinceObj.districts,
    );
    if (selected != null) setState(() => _selectedDistrict = selected);
  }

  Future<void> _onSaveProfile() async {
    final l10n = context.l10n;
    // Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    final fullName = _fullNameController.text.trim();

    if (fullName.isEmpty) {
      setState(() => _errorMessage = l10n.wizardFullNameRequiredError);
      return;
    }

    final age = DateTime.now().year - _birthDate.year;
    if (age < remoteConfig.minDonorAge || age > remoteConfig.maxDonorAge) {
      setState(
        () => _errorMessage = l10n.wizardAgeValidationError(
          remoteConfig.minDonorAge,
          remoteConfig.maxDonorAge,
        ),
      );
      return;
    }

    final weight = int.tryParse(_weightController.text.trim()) ?? 0;
    if (weight < remoteConfig.minDonorWeightKg) {
      setState(
        () => _errorMessage = l10n.wizardWeightValidationError(
          remoteConfig.minDonorWeightKg,
        ),
      );
      return;
    }

    if (_selectedProvince == null || _selectedDistrict == null) {
      setState(() => _errorMessage = l10n.wizardLocationRequiredError);
      return;
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

    if (!mounted) return;
    setState(() => _isSaving = false);
    ref.read(profileCompletedStateProvider.notifier).state = true;
    context.go(AppRoutes.requests);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provincesAsync = ref.watch(turkeyProvincesProvider);
    final provinces = provincesAsync.valueOrNull ?? const <TurkeyProvince>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wizardTitle)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(l10n.wizardStepIdentity, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('wizard_full_name_field'),
                  controller: _fullNameController,
                  labelText: l10n.wizardFullNameLabel,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('wizard_nickname_field'),
                  controller: _nicknameController,
                  labelText: l10n.wizardNicknameLabel,
                  prefixIcon: Icons.badge_outlined,
                ),
                SwitchListTile(
                  value: _useNickname,
                  onChanged: (val) => setState(() => _useNickname = val),
                  title: Text(l10n.wizardUseNicknameSwitch),
                ),
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
                const Divider(height: AppSpacing.xl),
                Text(l10n.wizardStepMedical, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<UserGender>(
                  initialValue: _gender,
                  decoration: InputDecoration(labelText: l10n.wizardGenderLabel),
                  items: [
                    DropdownMenuItem(value: UserGender.male, child: Text(l10n.wizardGenderMale)),
                    DropdownMenuItem(value: UserGender.female, child: Text(l10n.wizardGenderFemale)),
                    DropdownMenuItem(value: UserGender.unspecified, child: Text(l10n.wizardGenderUnspecified)),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('wizard_weight_field'),
                  controller: _weightController,
                  labelText: l10n.wizardWeightLabel,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.monitor_weight_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.wizardBloodTypeLabel, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final type in BloodType.knownTypes)
                      ChoiceChip(
                        label: Text(type.code),
                        selected: _bloodType == type,
                        onSelected: (_) => setState(() => _bloodType = type),
                      ),
                    ChoiceChip(
                      key: const Key('blood_type_unknown_chip'),
                      label: Text(l10n.wizardBloodTypeUnknownOption),
                      selected: _bloodType == BloodType.unknown,
                      onSelected: (_) => setState(() => _bloodType = BloodType.unknown),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push(AppRoutes.unknownBloodTypeGuide),
                    icon: const Icon(Icons.help_outline_rounded),
                    label: Text(l10n.wizardBloodTypeHowToLearnLink),
                  ),
                ),
                const Divider(height: AppSpacing.xl),
                Text(l10n.wizardStepLocation, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  key: const Key('select_province_tile'),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  title: Text(_selectedProvince ?? l10n.wizardProvinceLabel),
                  trailing: const Icon(Icons.search_rounded),
                  onTap: () => _selectProvince(provinces),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  key: const Key('select_district_tile'),
                  enabled: _selectedProvince != null,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  title: Text(_selectedDistrict ?? l10n.wizardDistrictLabel),
                  trailing: const Icon(Icons.search_rounded),
                  onTap: () => _selectDistrict(provinces),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.wizardCompleteButton,
                  isLoading: _isSaving,
                  onPressed: _onSaveProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

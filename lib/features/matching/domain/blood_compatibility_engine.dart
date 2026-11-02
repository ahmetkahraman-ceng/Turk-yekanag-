import 'package:turkiye_kan_agi/features/profile/domain/blood_type.dart';
import 'package:turkiye_kan_agi/features/requests/domain/blood_product_type.dart';

/// Kan grubu ve kan bileşeni (ürün tipi) uyumluluk motoru.
/// Saf Dart fonksiyonu olarak yazılmıştır; Cloud Functions (`bloodCompatibility.ts`)
/// ile birebir aynı kuralları uygular.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
abstract final class BloodCompatibilityEngine {
  /// Bağışçının (`donor`) kan grubunun, alıcının (`recipient`) kan grubuna ve
  /// istenen ürün tipine (`productType`) göre uyumlu olup olmadığını döner.
  /// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
  static bool isCompatible({
    required BloodType donor,
    required BloodType recipient,
    required BloodProductType productType,
  }) {
    if (!donor.isKnown || !recipient.isKnown) {
      return false;
    }

    switch (productType) {
      case BloodProductType.wholeBlood:
        // Tam kan naklinde izogrup (birebir aynı ABO ve Rh) aranır.
        return donor == recipient;

      case BloodProductType.erythrocyte:
        // Eritrosit süspansiyonu: 0 Rh(-) genel verici, AB Rh(+) genel alıcı.
        return _isRhCompatibleForCells(donor: donor, recipient: recipient) &&
            _isAboCompatibleForErythrocyte(
              donorAbo: _aboGroup(donor),
              recipientAbo: _aboGroup(recipient),
            );

      case BloodProductType.plasma:
        // Taze Donmuş Plazma (TDP): Eritrosit ABO uyumunun tersidir.
        // AB grubu plazma genel vericisidir, 0 grubu plazma genel alıcısıdır.
        return _isAboCompatibleForPlasma(
          donorAbo: _aboGroup(donor),
          recipientAbo: _aboGroup(recipient),
        );

      case BloodProductType.platelet:
        // Trombosit (Aferez): ABO özdeşliği ve Rh hücre uyumu tercih edilir.
        return _aboGroup(donor) == _aboGroup(recipient) &&
            _isRhCompatibleForCells(donor: donor, recipient: recipient);
    }
  }

  /// Belirli bir alıcı kan grubu ve ürün tipi için uyumlu tüm bağışçı kan gruplarını döner.
  static List<BloodType> compatibleDonorTypesFor({
    required BloodType recipient,
    required BloodProductType productType,
  }) {
    return BloodType.knownTypes
        .where(
          (donor) => isCompatible(
            donor: donor,
            recipient: recipient,
            productType: productType,
          ),
        )
        .toList(growable: false);
  }

  static String _aboGroup(BloodType type) {
    switch (type) {
      case BloodType.aPos:
      case BloodType.aNeg:
        return 'A';
      case BloodType.bPos:
      case BloodType.bNeg:
        return 'B';
      case BloodType.abPos:
      case BloodType.abNeg:
        return 'AB';
      case BloodType.oPos:
      case BloodType.oNeg:
        return '0';
      case BloodType.unknown:
        return '';
    }
  }

  static bool _isRhPositive(BloodType type) {
    return type == BloodType.aPos ||
        type == BloodType.bPos ||
        type == BloodType.abPos ||
        type == BloodType.oPos;
  }

  /// Hücresel ürünlerde Rh(-) hem Rh(-) hem Rh(+) alıcıya verebilir;
  /// Rh(+) yalnızca Rh(+) alıcıya verebilir.
  static bool _isRhCompatibleForCells({
    required BloodType donor,
    required BloodType recipient,
  }) {
    final donorPos = _isRhPositive(donor);
    final recipientPos = _isRhPositive(recipient);
    if (donorPos && !recipientPos) {
      return false;
    }
    return true;
  }

  /// Eritrosit ABO uyumu:
  /// 0 -> 0, A, B, AB
  /// A -> A, AB
  /// B -> B, AB
  /// AB -> AB
  static bool _isAboCompatibleForErythrocyte({
    required String donorAbo,
    required String recipientAbo,
  }) {
    switch (donorAbo) {
      case '0':
        return true;
      case 'A':
        return recipientAbo == 'A' || recipientAbo == 'AB';
      case 'B':
        return recipientAbo == 'B' || recipientAbo == 'AB';
      case 'AB':
        return recipientAbo == 'AB';
      default:
        return false;
    }
  }

  /// Plazma ABO uyumu (Eritrositin tersi):
  /// AB -> AB, A, B, 0
  /// A -> A, 0
  /// B -> B, 0
  /// 0 -> 0
  static bool _isAboCompatibleForPlasma({
    required String donorAbo,
    required String recipientAbo,
  }) {
    switch (donorAbo) {
      case 'AB':
        return true;
      case 'A':
        return recipientAbo == 'A' || recipientAbo == '0';
      case 'B':
        return recipientAbo == 'B' || recipientAbo == '0';
      case '0':
        return recipientAbo == '0';
      default:
        return false;
    }
  }
}

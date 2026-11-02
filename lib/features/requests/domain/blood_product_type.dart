/// Kan ürünü / bileşeni tipleri.
/// Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
enum BloodProductType {
  wholeBlood('whole_blood'),
  erythrocyte('erythrocyte'),
  platelet('platelet'),
  plasma('plasma');

  const BloodProductType(this.code);
  final String code;

  bool get isApheresis => this == BloodProductType.platelet;

  static BloodProductType fromCode(String? raw) {
    for (final item in BloodProductType.values) {
      if (item.code == raw) return item;
    }
    return BloodProductType.wholeBlood;
  }
}

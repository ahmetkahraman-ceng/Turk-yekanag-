/// Kan talebi yaşam döngüsü durumları.
enum RequestStatus {
  open('open'),
  fulfilled('fulfilled'),
  cancelled('cancelled'),
  expired('expired');

  const RequestStatus(this.code);
  final String code;

  bool get isActive => this == RequestStatus.open;

  static RequestStatus fromCode(String? raw) {
    for (final item in RequestStatus.values) {
      if (item.code == raw) return item;
    }
    return RequestStatus.open;
  }
}

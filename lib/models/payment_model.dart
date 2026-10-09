class PaymentMethod {
  final String id;
  final String name;
  final String account;
  final String holder;
  final num fee;
  final bool active;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.account,
    required this.holder,
    required this.fee,
    required this.active,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Payment',
      account: map['account'] ?? '',
      holder: map['holder'] ?? '',
      fee: map['fee'] ?? 0,
      active: map['active'] != false,
    );
  }
}

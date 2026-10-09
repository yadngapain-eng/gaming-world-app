class Order {
  final String id;
  final String userId;
  final String item;
  final String product;
  final num price;
  final num total;
  final String payment;
  final String status;
  final String? date;
  final Map<String, dynamic> userData;

  Order({
    required this.id,
    required this.userId,
    required this.item,
    required this.product,
    required this.price,
    required this.total,
    required this.payment,
    required this.status,
    this.date,
    required this.userData,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      item: map['item'] ?? '',
      product: map['product'] ?? '',
      price: map['price'] ?? 0,
      total: map['total'] ?? 0,
      payment: map['payment'] ?? '',
      status: map['status'] ?? 'pending',
      date: map['date'],
      userData: Map<String, dynamic>.from(map['userData'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'item': item,
      'product': product,
      'price': price,
      'total': total,
      'payment': payment,
      'status': status,
      'date': date,
      'userData': userData,
    };
  }
}

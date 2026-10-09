class ShopItem {
  final String id;
  final String gameId;
  final String gameName;
  final String gameIcon;
  final String product;
  final num price;
  final num priceKoin;
  final String? bonus;

  ShopItem({
    required this.id,
    required this.gameId,
    required this.gameName,
    required this.gameIcon,
    required this.product,
    required this.price,
    required this.priceKoin,
    this.bonus,
  });

  factory ShopItem.fromGameProduct(
    Map<String, dynamic> game,
    Map<String, dynamic> product,
    num markup,
  ) {
    final basePrice = (product['price'] ?? 0) as num;
    final finalPrice = basePrice + markup;
    return ShopItem(
      id: game['id'].toString() + '_' + product['id'].toString(),
      gameId: game['id'] ?? '',
      gameName: game['name'] ?? '',
      gameIcon: game['icon'] ?? '',
      product: product['name'] ?? '',
      price: finalPrice,
      priceKoin: finalPrice,
      bonus: product['bonus'],
    );
  }
}

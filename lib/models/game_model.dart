class Game {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String url;
  final bool active;
  final num? price;

  Game({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.url,
    required this.active,
    this.price,
  });

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Game',
      icon: map['icon'] ?? '🎮',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      active: map['active'] != false,
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'url': url,
      'active': active,
      'price': price,
    };
  }
}

class MenuItem {
  final int id;
  final String name;
  final double price;
  final String image;
  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
    };
  }
}

class Restaurant {
  final int id;
  final String name;
  final double rating;
  final String cuisine;
  final String category;
  final String image;
  final String deliveryTime;
  final String? offer;
  final List<MenuItem> menu;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.cuisine,
    required this.category,
    required this.image,
    required this.deliveryTime,
    this.offer,
    required this.menu,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var rawMenu = json['menu'] as List<dynamic>? ?? [];
    List<MenuItem> menuList = rawMenu.map((item) => MenuItem.fromJson(item as Map<String, dynamic>)).toList();

    return Restaurant(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : double.tryParse(json['rating'].toString()) ?? 0.0,
      cuisine: json['cuisine'] ?? '',
      category: json['category'] ?? 'Continental',
      image: json['image'] ?? '',
      deliveryTime: json['deliveryTime'] ?? '30 mins',
      offer: json['offer'],
      menu: menuList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'cuisine': cuisine,
      'category': category,
      'image': image,
      'deliveryTime': deliveryTime,
      'offer': offer,
      'menu': menu.map((m) => m.toJson()).toList(),
    };
  }
}


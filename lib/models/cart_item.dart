import 'restaurant.dart';

class CartItem {
  final int id;
  final String name;
  final double price;
  final String image;
  final String description;
  int quantity;
  final int? restaurantId;
  final String? restaurantName;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    this.quantity = 1,
    this.restaurantId,
    this.restaurantName,
  });

  factory CartItem.fromMenuItem(MenuItem item, {int? restaurantId, String? restaurantName}) {
    return CartItem(
      id: item.id,
      name: item.name,
      price: item.price,
      image: item.image,
      description: item.description,
      quantity: 1,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'quantity': quantity,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
    };
  }

  double get totalPrice => price * quantity;
}


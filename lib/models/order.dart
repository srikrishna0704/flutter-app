import 'cart_item.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final String address;
  String status;
  final String deliveryTime;
  final String estimatedArrival;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.address,
    this.status = 'Preparing',
    this.deliveryTime = '30 - 45 mins',
    required this.estimatedArrival,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<CartItem> parsedItems = rawItems.map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList();

    String parsedAddress = '';
    if (json['address'] is Map) {
      final addrMap = json['address'];
      parsedAddress = '${addrMap['address'] ?? ''}, ${addrMap['city'] ?? ''}'.trim();
    } else {
      parsedAddress = json['address']?.toString() ?? '';
    }

    return Order(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      items: parsedItems,
      totalPrice: (json['totalPrice'] is num)
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse(json['totalPrice'].toString()) ?? 0.0,
      address: parsedAddress,
      status: json['status'] ?? 'Preparing',
      deliveryTime: json['deliveryTime'] ?? '30 - 45 mins',
      estimatedArrival: json['estimatedArrival'] ?? '35 mins',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'totalPrice': totalPrice,
      'address': address,
      'status': status,
      'deliveryTime': deliveryTime,
      'estimatedArrival': estimatedArrival,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get shortId => id.length > 8 ? id.substring(id.length - 8).toUpperCase() : id.toUpperCase();
}


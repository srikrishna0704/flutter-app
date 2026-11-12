import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/restaurant.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  int getItemQuantity(int itemId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      return _items[index].quantity;
    }
    return 0;
  }

  void addItem(MenuItem item, {int? restaurantId, String? restaurantName}) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem.fromMenuItem(
        item,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(int itemId, int quantity) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void removeItem(int itemId) {
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get tax {
    return subtotal * 0.18; // 18% GST matches original React code
  }

  double get deliveryFee => 0.0; // Free delivery

  double get grandTotal {
    return subtotal + tax + deliveryFee;
  }
}


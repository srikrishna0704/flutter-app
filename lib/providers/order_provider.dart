import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  Order? get activeOrder {
    if (_orders.isEmpty) return null;
    final latest = _orders.first;
    // If order was placed within last 2 hours or is not yet marked Delivered
    final diffHours = DateTime.now().difference(latest.createdAt).inHours;
    if (diffHours < 2 || latest.status != 'Delivered') {
      return latest;
    }
    return null;
  }

  OrderProvider() {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    _isLoading = true;
    notifyListeners();

    _orders = await StorageService.getOrders();
    _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final savedUser = await StorageService.getUser();
    if (savedUser != null && ApiService.isMongoObjectId(savedUser.id)) {
      final remoteOrders = await ApiService.getOrders(savedUser.id);
      if (remoteOrders != null) {
        _orders = remoteOrders;
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        await StorageService.saveOrders(_orders);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> syncOrders(String userId) async {
    if (!ApiService.isMongoObjectId(userId)) return;
    _isLoading = true;
    notifyListeners();

    final remoteOrders = await ApiService.getOrders(userId);
    if (remoteOrders != null) {
      _orders = remoteOrders;
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await StorageService.saveOrders(_orders);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double totalPrice,
    required String address,
  }) async {
    final now = DateTime.now();
    final arrivalTime = now.add(const Duration(minutes: 35));
    final arrivalStr = DateFormat('hh:mm a').format(arrivalTime);

    final payload = {
      'userId': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'totalPrice': totalPrice,
      'address': address,
      'status': 'Preparing',
      'deliveryTime': '30 - 45 mins',
      'estimatedArrival': arrivalStr,
    };

    // Try saving to MongoDB backend first if user is a real MongoDB user
    Order? remoteOrder = await ApiService.placeOrder(payload);

    final order = remoteOrder ??
        Order(
          id: 'ORD${now.millisecondsSinceEpoch.toString().substring(5)}',
          userId: userId,
          items: List.from(items),
          totalPrice: totalPrice,
          address: address,
          status: 'Preparing',
          deliveryTime: '30 - 45 mins',
          estimatedArrival: arrivalStr,
          createdAt: now,
        );

    _orders.insert(0, order);
    await StorageService.saveOrders(_orders);
    notifyListeners();

    // Simulate real-time status updates for demonstration
    _startOrderStatusSimulation(order);

    return order;
  }

  void _startOrderStatusSimulation(Order order) {
    // After 25 seconds, switch to "Out for Delivery"
    Timer(const Duration(seconds: 25), () {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index >= 0) {
        _orders[index].status = 'Out for Delivery';
        StorageService.saveOrders(_orders);
        notifyListeners();
      }
    });

    // After 60 seconds, switch to "Delivered"
    Timer(const Duration(seconds: 60), () {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index >= 0) {
        _orders[index].status = 'Delivered';
        StorageService.saveOrders(_orders);
        notifyListeners();
      }
    });
  }
}

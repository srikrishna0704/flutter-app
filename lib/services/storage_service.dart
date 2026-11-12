import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/order.dart';

class StorageService {
  static const String _userKey = 'foodkart_user';
  static const String _tokenKey = 'foodkart_token';
  static const String _addressesKey = 'foodkart_addresses';
  static const String _ordersKey = 'foodkart_orders';
  static const String _favoritesKey = 'foodkart_favorites';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    if (user.token != null) {
      await prefs.setString(_tokenKey, user.token!);
    }
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);
    if (userStr != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(userStr);
        return User.fromJson(map, token: token);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveAddresses(List<Address> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final list = addresses.map((a) => a.toJson()).toList();
    await prefs.setString(_addressesKey, jsonEncode(list));
  }

  static Future<List<Address>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_addressesKey);
    if (str != null) {
      try {
        final List<dynamic> list = jsonDecode(str);
        return list.map((item) => Address.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final list = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_ordersKey, jsonEncode(list));
  }

  static Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_ordersKey);
    if (str != null) {
      try {
        final List<dynamic> list = jsonDecode(str);
        return list.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<void> saveFavoriteIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.map((id) => id.toString()).toList());
  }

  static Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey);
    if (list != null) {
      return list.map((s) => int.tryParse(s) ?? 0).where((id) => id > 0).toList();
    }
    return [];
  }
}


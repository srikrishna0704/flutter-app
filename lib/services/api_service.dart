import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/user.dart';
import '../models/order.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, [this.statusCode = 400]);

  @override
  String toString() => message;
}

class ApiService {
  // Points to the live deployed FoodKart FSD backend (MongoDB Atlas + Express).
  // Can be overridden at build time using:
  // flutter build apk --release --dart-define=API_URL=http://<YOUR_LAN_IP>:5000/api
  static String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://food-kart-five.vercel.app/api',
  );

  static const Duration _timeout = Duration(seconds: 10);

  static bool isMongoObjectId(String id) {
    return RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);
  }

  static Future<List<Restaurant>?> getRestaurants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/restaurants')).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Network unavailable -> caller falls back to bundled catalog data
    }
    return null;
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : null;
      }

      if (response.statusCode >= 400 && response.statusCode < 500) {
        final msg = decoded is Map ? (decoded['message']?.toString() ?? 'Invalid credentials') : 'Invalid credentials';
        throw ApiException(msg, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      // Network unavailable -> return null so AuthProvider can handle offline fallback
    }
    return null;
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded is Map<String, dynamic> ? decoded : null;
      }

      if (response.statusCode >= 400 && response.statusCode < 500) {
        final msg = decoded is Map ? (decoded['message']?.toString() ?? 'Registration failed') : 'Registration failed';
        throw ApiException(msg, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      // Network unavailable -> return null so AuthProvider can handle offline fallback
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    if (!isMongoObjectId(userId)) return null;
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/profile'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'name': name,
              'email': email,
              'phone': phone,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : null;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<Order>?> getOrders(String userId) async {
    if (!isMongoObjectId(userId)) return null;
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/$userId')).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<Order?> placeOrder(Map<String, dynamic> orderData) async {
    final userId = orderData['userId']?.toString() ?? '';
    if (!isMongoObjectId(userId)) return null;
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/place'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(orderData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['order'] is Map<String, dynamic>) {
          return Order.fromJson(decoded['order'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<List<Address>?> getAddresses(String userId) async {
    if (!isMongoObjectId(userId)) return null;
    try {
      final response = await http.get(Uri.parse('$baseUrl/address/$userId')).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Address.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return null;
  }

  static Future<Address?> addAddress(Map<String, dynamic> addressData) async {
    final userId = addressData['userId']?.toString() ?? '';
    if (!isMongoObjectId(userId)) return null;
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/address/add'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(addressData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['address'] is Map<String, dynamic>) {
          return Address.fromJson(decoded['address'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }
}

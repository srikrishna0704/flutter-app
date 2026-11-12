import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  List<Address> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _user = await StorageService.getUser();
    _addresses = await StorageService.getAddresses();

    if (_user != null && ApiService.isMongoObjectId(_user!.id)) {
      final remoteAddresses = await ApiService.getAddresses(_user!.id);
      if (remoteAddresses != null && remoteAddresses.isNotEmpty) {
        _addresses = remoteAddresses;
        await StorageService.saveAddresses(_addresses);
      }
    }

    // Default sample address if none exists
    if (_addresses.isEmpty) {
      _addresses = [
        Address(
          id: 'addr_1',
          fullName: _user?.name ?? 'Chaitanya',
          address: 'Plot 42, Hitech City, Madhapur',
          city: 'Hyderabad',
          pincode: '500081',
          state: 'Telangana',
          phone: _user?.phone.isNotEmpty == true ? _user!.phone : '9876543210',
        ),
      ];
      await StorageService.saveAddresses(_addresses);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.login(email, password);
      if (res != null && res['user'] != null) {
        _user = User.fromJson(res['user'], token: res['token']);
        // Sync addresses from MongoDB backend
        final remoteAddresses = await ApiService.getAddresses(_user!.id);
        if (remoteAddresses != null) {
          _addresses = remoteAddresses;
          await StorageService.saveAddresses(_addresses);
        }
      } else {
        // Offline / unreachable backend fallback login
        _user = User(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first,
          email: email,
          phone: '9876543210',
          token: 'jwt_mock_token',
        );
      }

      await StorageService.saveUser(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, {String phone = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.register(name, email, password);
      if (res != null && res['user'] != null) {
        _user = User.fromJson(res['user'], token: res['token']);
        if (phone.isNotEmpty) {
          await ApiService.updateProfile(
            userId: _user!.id,
            name: name,
            email: email,
            phone: phone,
          );
          _user = _user!.copyWith(phone: phone);
        }
      } else {
        _user = User(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          phone: phone,
          token: 'jwt_mock_token',
        );
      }

      await StorageService.saveUser(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> quickDemoLogin() async {
    _isLoading = true;
    notifyListeners();

    _user = User(
      id: 'usr_demo_101',
      name: 'Chaitanya',
      email: 'chaitanya@foodkart.com',
      phone: '+91 98765 43210',
      token: 'mock_demo_token',
    );
    await StorageService.saveUser(_user!);

    if (_addresses.isEmpty) {
      _addresses = [
        Address(
          id: 'addr_demo',
          fullName: 'Chaitanya',
          address: 'Flat 302, Green Meadows, Gachibowli',
          city: 'Hyderabad',
          pincode: '500032',
          state: 'Telangana',
          phone: '9876543210',
        ),
      ];
      await StorageService.saveAddresses(_addresses);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await StorageService.clearUser();
    notifyListeners();
  }

  Future<void> updateProfile({required String name, required String email, required String phone}) async {
    if (_user == null) return;

    final res = await ApiService.updateProfile(
      userId: _user!.id,
      name: name,
      email: email,
      phone: phone,
    );

    if (res != null && res['user'] != null) {
      _user = User.fromJson(res['user'], token: _user!.token);
    } else {
      _user = _user!.copyWith(name: name, email: email, phone: phone);
    }

    await StorageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> addAddress(String fullAddress, {String city = 'Hyderabad'}) async {
    Address? newAddr;

    if (_user != null && ApiService.isMongoObjectId(_user!.id)) {
      newAddr = await ApiService.addAddress({
        'userId': _user!.id,
        'fullName': _user!.name,
        'address': fullAddress,
        'city': city,
        'pincode': '500001',
        'state': 'Telangana',
        'phone': _user!.phone.isNotEmpty ? _user!.phone : '9876543210',
      });
    }

    newAddr ??= Address(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _user?.name ?? 'User',
      address: fullAddress,
      city: city,
      pincode: '500001',
      state: 'Telangana',
      phone: _user?.phone.isNotEmpty == true ? _user!.phone : '9876543210',
    );

    _addresses.add(newAddr);
    await StorageService.saveAddresses(_addresses);
    notifyListeners();
  }

  Future<void> deleteAddress(String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
    await StorageService.saveAddresses(_addresses);
    notifyListeners();
  }
}

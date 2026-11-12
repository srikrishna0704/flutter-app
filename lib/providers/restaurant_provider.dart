import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../data/sample_data.dart';
import '../services/api_service.dart';

class RestaurantProvider extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Restaurant> get allRestaurants => List.unmodifiable(_restaurants);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final set = <String>{'All'};
    for (var r in _restaurants) {
      set.add(r.category);
    }
    return set.toList();
  }

  List<Restaurant> get filteredRestaurants {
    final query = _searchQuery.trim().toLowerCase();

    return _restaurants.where((r) {
      final matchesCategory = _selectedCategory == 'All' || r.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      final matchesName = r.name.toLowerCase().contains(query);
      final matchesCuisine = r.cuisine.toLowerCase().contains(query);
      final matchesMenu = r.menu.any((m) =>
          m.name.toLowerCase().contains(query) ||
          m.description.toLowerCase().contains(query));

      return matchesName || matchesCuisine || matchesMenu;
    }).toList();
  }

  List<Restaurant> get offers {
    return _restaurants.where((r) => r.offer != null && r.offer!.isNotEmpty).toList();
  }

  RestaurantProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    _restaurants = List.from(initialRestaurants);
    notifyListeners();

    await refreshRestaurants();
  }

  Future<void> refreshRestaurants() async {
    try {
      final remoteList = await ApiService.getRestaurants();
      if (remoteList != null && remoteList.isNotEmpty) {
        _restaurants = remoteList;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Restaurant? getRestaurantById(int id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}


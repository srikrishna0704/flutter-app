import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<int> _favoriteIds = [];

  List<int> get favoriteIds => List.unmodifiable(_favoriteIds);

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await StorageService.getFavoriteIds();
    _favoriteIds.clear();
    _favoriteIds.addAll(ids);
    notifyListeners();
  }

  bool isFavorite(int id) {
    return _favoriteIds.contains(id);
  }

  Future<void> toggleFavorite(int id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await StorageService.saveFavoriteIds(_favoriteIds);
    notifyListeners();
  }

  List<Restaurant> getFavoriteRestaurants(List<Restaurant> allRestaurants) {
    return allRestaurants.where((r) => _favoriteIds.contains(r.id)).toList();
  }
}

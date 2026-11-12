import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/restaurant_card.dart';
import '../main_navigation_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<FavoritesProvider, RestaurantProvider>(
        builder: (context, favProvider, restProvider, _) {
          final favRestaurants = favProvider.getFavoriteRestaurants(restProvider.allRestaurants);

          if (favRestaurants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 72,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your favorites list is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on any restaurant to save it here for later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(initialIndex: 1),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('Explore Restaurants'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favRestaurants.length,
            itemBuilder: (context, index) {
              return RestaurantCard(restaurant: favRestaurants[index]);
            },
          );
        },
      ),
    );
  }
}


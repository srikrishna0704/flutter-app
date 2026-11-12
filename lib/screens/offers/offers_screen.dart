import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_theme.dart';
import '../restaurants/restaurant_detail_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String _activeTab = 'All';
  String _searchTerm = '';

  final List<String> _tabs = ['All', 'Percentage', 'Flat', 'Freebies'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Delicious Offers For You'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, _) {
          final allOffers = provider.offers;

          final filtered = allOffers.where((res) {
            final offerStr = res.offer ?? '';
            final matchesSearch = res.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                offerStr.toLowerCase().contains(_searchTerm.toLowerCase());

            bool matchesTab = true;
            if (_activeTab == 'Percentage') {
              matchesTab = offerStr.contains('%');
            } else if (_activeTab == 'Flat') {
              matchesTab = offerStr.toLowerCase().contains('flat');
            } else if (_activeTab == 'Freebies') {
              matchesTab = offerStr.toLowerCase().contains('free') || offerStr.toLowerCase().contains('bogo');
            }

            return matchesSearch && matchesTab;
          }).toList();

          return Column(
            children: [
              // Search Deals
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchTerm = val),
                  decoration: InputDecoration(
                    hintText: 'Search deals & coupons...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                    isDense: true,
                  ),
                ),
              ),

              // Filter Tabs
              Container(
                color: Colors.white,
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    final isSelected = _activeTab == tab;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _activeTab = tab),
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkTextColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // Offer Cards List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text(
                              'No active offers found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try selecting another category',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final res = filtered[index];
                          final couponCode = 'FOODKART${res.id}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantDetailScreen(restaurantId: res.id),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'OFFER',
                                              style: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            res.offer ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.darkTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'at ${res.name}',
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                          ),
                                          const SizedBox(height: 12),
                                          // Coupon Code
                                          GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: couponCode));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Coupon "$couponCode" copied!'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.amber.shade300, style: BorderStyle.solid),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.confirmation_number_outlined, size: 14, color: Colors.brown),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      'Code: $couponCode',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.brown,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.copy, size: 12, color: Colors.brown),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: CachedNetworkImage(
                                      imageUrl: res.image,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Container(
                                        height: 150,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.local_offer, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


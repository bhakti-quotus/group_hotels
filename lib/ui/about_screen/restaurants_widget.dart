import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

class RestaurantsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants;

  const RestaurantsWidget({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.cardBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurants & Bars',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          const SizedBox(height: 16),
          ...restaurants.map((restaurant) {
            final isLast = restaurant == restaurants.last;
            return Column(
              children: [
                _buildRestaurantCard(restaurant),
                if (!isLast) const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: Image.network(
              restaurant['image'] ?? '',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['name'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.text,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColor.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      restaurant['timing'] ?? '',
                      style: TextStyle(fontSize: 13, color: AppColor.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

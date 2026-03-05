import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/utils/app_routes.dart';

class FeaturedHotelsSection extends StatelessWidget {
  final List<dynamic> hotels;

  const FeaturedHotelsSection({Key? key, required this.hotels})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Our Hotels',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.text,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/hotels');
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...hotels.map((hotel) => HotelCard(hotel: hotel)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class HotelCard extends StatelessWidget {
  final Map<String, dynamic> hotel;

  const HotelCard({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = hotel['config'] as Map<String, dynamic>? ?? {};
    //final branding = config['branding'] as Map<String, dynamic>? ?? {};
    final contact = config['contact'] as Map<String, dynamic>? ?? {};
    final rooms = config['rooms'] as List<dynamic>? ?? [];
    final lowestPrice = rooms.isNotEmpty
        ? rooms
                  .map((r) => r['basePrice'] as int?)
                  .where((p) => p != null)
                  .reduce((a, b) => a! < b! ? a : b) ??
              0
        : 0;

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.home, arguments: config);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Container(
            //   width: 80,
            //   height: 80,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(8),
            //     image: branding['logo'] != null
            //         ? DecorationImage(
            //             image: NetworkImage(branding['logo']),
            //             fit: BoxFit.cover,
            //           )
            //         : null,
            //     color: Colors.grey.shade200,
            //   ),
            //   child: branding['logo'] == null
            //       ? const Icon(Icons.hotel, size: 40, color: Colors.grey)
            //       : null,
            // ),
            // const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel['name'] ?? 'Hotel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact['address'] ?? 'Address not available',
                    style: TextStyle(fontSize: 14, color: AppColor.textLight),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Starting from AED $lowestPrice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColor.textLight),
          ],
        ),
      ),
    );
  }
}

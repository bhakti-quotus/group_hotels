import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/utils/app_routes.dart';

class FeaturedRoomsSection extends StatelessWidget {
  final Map<String, dynamic> featuredRooms;

  const FeaturedRoomsSection({Key? key, required this.featuredRooms})
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
              'Featured Rooms',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.text,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.rooms);
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

        // Button tile instead of room list
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.rooms);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.secondary, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.hotel, color: AppColor.secondary, size: 24),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Featured Rooms',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        //'${featuredRooms['data']['rooms']?.length ?? 0} rooms available',
                        'view our curated selection of rooms handpicked for you',
                        style: TextStyle(fontSize: 11, color: AppColor.text),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: AppColor.text, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

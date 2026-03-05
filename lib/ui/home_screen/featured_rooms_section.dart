import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/utils/app_routes.dart';
import 'room_card.dart';

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
        ...(featuredRooms['data']['rooms'] as List).map(
          (room) => RoomCard(room: room),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

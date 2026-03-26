import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/utils/app_routes.dart';

class WebRoomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const WebRoomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _handleTabTap(int index, BuildContext context) {
    final hotelController = Get.find<HotelController>();
    
    // Tabs: 0=Home, 1=Schedule, 2=Messages, 3=Reservation, 4=Profile
    // Disable Schedule (1) and Messages (2) if not registered
    if ((index == 1 || index == 2) && !hotelController.isRegistered.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Login required to access this content')),
            ],
          ),
          backgroundColor: AppColor.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Get.offNamed(AppRoutes.webroomChildLogin);
      return;
    }

    final List<String> routes = [
      AppRoutes.webroomChildHome,
      AppRoutes.webroomChildSchedule,
      AppRoutes.webroomChildMessages,
      AppRoutes.webroomChildReservation,
      AppRoutes.webroomChildProfile,
    ];

    if (index < routes.length) {
      Get.offNamed(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelController = Get.find<HotelController>();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 0,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: AppColor.primary,
          unselectedItemColor: Colors.grey[700],
          backgroundColor: Colors.white,
          elevation: 0, // Remove default elevation
          onTap: (index) => _handleTabTap(index, context),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.schedule,
                color: !hotelController.isRegistered.value
                    ? Colors.grey[300]
                    : null,
              ),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
                color: !hotelController.isRegistered.value
                    ? Colors.grey[300]
                    : null,
              ),
              label: 'Messages',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.book_online), label: 'Reservation'),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
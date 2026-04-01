import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/group/controllers/hotel_controller.dart';
import 'package:sunswept/group/utils/app_routes.dart';
import 'group_webroom_child_home_page.dart';
import 'group_webroom_child_schedule_page.dart';
import 'group_webroom_child_messages_page.dart';
import 'group_webroom_child_reservation_page.dart';
import 'group_webroom_child_profile_page.dart';

class GroupWebRoomChildMainPage extends StatefulWidget {
  const GroupWebRoomChildMainPage({super.key});

  @override
  State<GroupWebRoomChildMainPage> createState() => _GroupWebRoomChildMainPageState();
}

class _GroupWebRoomChildMainPageState extends State<GroupWebRoomChildMainPage> {
  int _currentIndex = 0;

  final List<String> _routes = [
    AppRoutes.webroomChildHome,
    AppRoutes.webroomChildSchedule,
    AppRoutes.webroomChildMessages,
    AppRoutes.webroomChildReservation,
    AppRoutes.webroomChildProfile,
  ];

  @override
  Widget build(BuildContext context) {
    final hotelController = Get.find<HotelController>();
    final selectedHotel = hotelController.getSelectedHotel();
    final hotelName = selectedHotel?['name'] as String? ?? 'Hotel';
    final hotelLogo = (selectedHotel?['config'] as Map<String, dynamic>?)?['branding']?['logo'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (hotelLogo != null && hotelLogo.isNotEmpty)
              Image.network(
                hotelLogo,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.hotel, color: Colors.white),
              )
            else
              const Icon(Icons.hotel, color: Colors.white),
            const SizedBox(width: 8),
            Text('Webroom - $hotelName'),
          ],
        ),
        backgroundColor: AppColor.primary,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          GroupWebRoomChildHomePage(),
          GroupWebRoomChildSchedulePage(),
          GroupWebRoomChildMessagesPage(),
          GroupWebRoomChildReservationPage(),
          GroupWebRoomChildProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Reservation'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

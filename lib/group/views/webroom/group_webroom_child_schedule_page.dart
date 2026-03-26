import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/views/webroom/controller/schedule_controller.dart';
import 'package:group/group/views/webroom/ui/schedule/schedule_view.dart';
import 'ui/webroom_bottom_navbar.dart';


class GroupWebRoomChildSchedulePage extends StatelessWidget {
  const GroupWebRoomChildSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller (lazy — safe to call multiple times)
    if (!Get.isRegistered<ScheduleController>()) {
      Get.put(ScheduleController());
    }

    final hotelController = Get.find<HotelController>();
    final selectedHotel = hotelController.getSelectedHotel();
    final hotelName = selectedHotel?['name'] as String? ?? 'Hotel';
    final hotelLogo =
        (selectedHotel?['config'] as Map<String, dynamic>?)?['branding']
            ?['logo'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
     

      // ← Just call ScheduleView here
      body: const ScheduleView(),

      bottomNavigationBar: const WebRoomBottomNavBar(currentIndex: 1),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => showAddEventSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
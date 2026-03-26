import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'ui/webroom_bottom_navbar.dart';

class GroupWebRoomChildReservationPage extends StatelessWidget {
  const GroupWebRoomChildReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelController = Get.find<HotelController>();
    final selectedHotel = hotelController.getSelectedHotel();
    final hotelName = selectedHotel?['name'] as String? ?? 'Hotel';
    final hotelLogo = (selectedHotel?['config'] as Map<String, dynamic>?)?['branding']?['logo'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Reservation', style: TextStyle(color: Color(0xFF003087), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF003087)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F1F5)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8414A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Reservation ID: 214783', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Travel Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003087))),
                  const SizedBox(height: 12),
                  _infoRow('Check-in', '18.04.2020', '10:00 a.m.'),
                  const SizedBox(height: 8),
                  _infoRow('Check-out', '28.04.2020', '12:00 p.m.'),
                  const SizedBox(height: 8),
                  _infoRow('Duration', '10 Nights', ''),
                  const SizedBox(height: 16),
                  const Text('Accommodation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003087))),
                  const SizedBox(height: 12),
                  _singleInfo('Room Type', 'Ocean View'),
                  const SizedBox(height: 8),
                  _singleInfo('Rooms', '1'),
                  const SizedBox(height: 8),
                  _singleInfo('Guests', '2 Adults'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const WebRoomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _infoRow(String label, String value, String time) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            if (time.isNotEmpty)
              Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF003087))),
          ],
        ),
      );

  Widget _singleInfo(String label, String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

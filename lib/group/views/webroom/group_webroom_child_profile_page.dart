import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';

class GroupWebRoomChildProfilePage extends StatelessWidget {
  const GroupWebRoomChildProfilePage({super.key});

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
      body: const Center(
        child: Text(
          'Profile Page Content',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
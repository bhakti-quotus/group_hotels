import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'ui/webroom_bottom_navbar.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Brian Dass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Member since 2019', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // edit profile action
                      Get.snackbar('Profile', 'Edit profile tapped');
                    },
                    child:  Icon(Icons.edit, color: AppColor.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _profileListTile(
              context,
              title: 'Personal info',
              icon: Icons.info_outline,
              onTap: () {
                Get.snackbar('Personal info', 'Personal info pressed');
              },
            ),
            const SizedBox(height: 10),
            _profileListTile(
              context,
              title: 'Preference',
              icon: Icons.favorite_border,
              onTap: () {
                Get.snackbar('Preference', 'Preference pressed');
              },
            ),
            const SizedBox(height: 10),
            _profileListTile(
              context,
              title: 'Settings',
              icon: Icons.settings_outlined,
              onTap: () {
                Get.snackbar('Settings', 'Settings pressed');
              },
            ),
            const SizedBox(height: 10),
            _profileListTile(
              context,
              title: 'FAQ',
              icon: Icons.help_outline,
              onTap: () {
                Get.snackbar('FAQ', 'FAQ pressed');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const WebRoomBottomNavBar(currentIndex: 4),
    );
  }

  Widget _profileListTile(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8EAF2)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColor.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
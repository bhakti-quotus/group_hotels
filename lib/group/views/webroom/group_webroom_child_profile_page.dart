import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero image header ──────────────────────────────────
              SizedBox(
                height: 250,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background nature photo
                    Positioned.fill(
                      child: Image.network(
                        'https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // White card peeking from bottom
                    Positioned(
                      bottom: -32,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                         color: const Color(0xFFF4F6FA),
                          //borderRadius: BorderRadius.circular(20),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.06),
                          //     blurRadius: 16,
                          //     offset: const Offset(0, 4),
                          //   ),
                          // ],
                        ),
                      ),
                    ),
                    // Avatar overlapping the card
                    Positioned(
                      bottom: -28,
                      left: 32,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 34,
                              backgroundImage: NetworkImage(
                                'https://randomuser.me/api/portraits/men/32.jpg',
                              ),
                            ),
                          ),
                          // Edit button at bottom-right of avatar
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => Get.snackbar('Profile', 'Edit profile tapped'),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 13,
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Name on the card
                    Positioned(
                      bottom: -10,
                      left: 116,
                      right: 28,
                      child: Text(
                        'Brian Dass',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E6C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 52),

              // ── Menu items ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    _profileListTile(
                      title: 'Personal info',
                      icon: Icons.info_outline,
                      onTap: () => Get.snackbar('Personal info', 'Personal info pressed'),
                    ),
                    const SizedBox(height: 12),
                    _profileListTile(
                      title: 'Preference',
                      icon: Icons.favorite_border,
                      onTap: () => Get.snackbar('Preference', 'Preference pressed'),
                    ),
                    const SizedBox(height: 12),
                    _profileListTile(
                      title: 'Settings',
                      icon: Icons.settings_outlined,
                      onTap: () => Get.snackbar('Settings', 'Settings pressed'),
                    ),
                    const SizedBox(height: 12),
                    _profileListTile(
                      title: 'FAQ',
                      icon: Icons.help_outline,
                      onTap: () => Get.snackbar('FAQ', 'FAQ pressed'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const WebRoomBottomNavBar(currentIndex: 4),
      ),
    );
  }

  Widget _profileListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColor.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A2E6C),
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  //shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Icon(Icons.chevron_right, color: Colors.red, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
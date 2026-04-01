import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sunswept/group/controllers/hotel_controller.dart';
import 'ui/webroom_bottom_navbar.dart';

class GroupWebRoomChildReservationPage extends StatelessWidget {
  const GroupWebRoomChildReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelController = Get.find<HotelController>();
    final selectedHotel = hotelController.getSelectedHotel();
    final hotelName = selectedHotel?['name'] as String? ?? 'Hotel';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.18),
                        ],
                      ),
                    ),
                  ),
                ),
                 Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white, // matches scaffold background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
      ),
    ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reservation ID badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8414A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Reservation ID: 214783',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Travel Details Section
                  const _SectionTitle('Travel Details'),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Check-in', value: '18.04.2020', trailing: '10:00 a.m.'),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Check-out', value: '28.04.2020', trailing: '12:00 p.m.'),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Duration', value: '10 Nights'),
                  const SizedBox(height: 28),

                  // Accommodation Section
                  const _SectionTitle('Accommodation'),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Room Type', value: 'Ocean View'),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Rooms', value: '1'),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Guests', value: '2 Adults'),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const WebRoomBottomNavBar(currentIndex: 3),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A2E6C),
        letterSpacing: 0.1,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? trailing;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 242, 246),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A94A6),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2E6C),
                ),
              ),
              if (trailing != null && trailing!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2E6C),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/views/webroom/ui/activity/Activities_spa_page.dart';
import 'package:group/group/views/webroom/ui/eat_and_drink/eat_and_drink_page.dart';
import 'package:group/group/views/webroom/ui/wellness/wellness_page.dart';

class WebroomHome extends StatefulWidget {
  const WebroomHome({super.key});

  @override
  State<WebroomHome> createState() => _WebroomHomeState();
}

class _WebroomHomeState extends State<WebroomHome> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _HeroSection(),
            const SizedBox(height: 20),
            _ServicesSection(), // Removed const to enable taps
            const SizedBox(height: 16),
            _CountdownSection(),
            const SizedBox(height: 16),
            const _GuestMessageCard(),
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
  final hotelController = Get.find<HotelController>();
    final selectedHotel = hotelController.getSelectedHotel();
    final logoUrl = selectedHotel?['config']?['branding']?['logo'] as String?;
    print('logoUrl: $logoUrl');

    print('logo ${logoUrl}');

   return Stack(
  children: [
    // Background image - NO borderRadius here
    Image.asset(
      'assets/images/home_bg.jpg',
      height: 330,
      width: double.infinity,
      fit: BoxFit.cover,
    ),

    // Gradient overlay - NO borderRadius here
    Container(
      height: 330,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black45,
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
    ),

    // Notification bell
    Positioned(
      top: 52,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
    ),

    // Weather + Logo
    Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 15),
                SizedBox(width: 5),
                Text(
                  '26°C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.20),
    borderRadius: BorderRadius.circular(12),
  ),
  child: logoUrl != null && logoUrl.isNotEmpty
      ? Image.network(
          logoUrl,
          height: 44,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'bodyholiday',
            style: TextStyle(
              color: Color(0xFFE8414A),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
      : const Text(
          'bodyholiday',
          style: TextStyle(
            color: Color(0xFFE8414A),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
),
        ],
      ),
    ),

    // ✅ White rounded overlay at the bottom corners
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 18,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6FA), // matches scaffold background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
      ),
    ),
  ],
);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICES SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Services',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  label: 'Wellness',
                  icon: Icons.spa_outlined,
                  iconColor: const Color(0xFF4CAF50),
                  onTap: () => Get.to(WellnessPage()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ServiceCard(
                  label: 'Activities',
                  icon: Icons.volunteer_activism_outlined,
                  iconColor: Color(0xFF2196F3),
                  onTap: () => Get.to(ActivitiesSpaPage()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ServiceCard(
                  label: 'Eat & Drink',
                  icon: Icons.restaurant_outlined,
                  iconColor: Color(0xFFE53935),
                  onTap: () => Get.to(EatAndDrinkPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ServiceCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COUNTDOWN SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownSection extends StatefulWidget {
  const _CountdownSection();

  @override
  State<_CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends State<_CountdownSection> {
  late Timer _timer;
  Duration _remaining = const Duration(
    days: 8,
    hours: 4,
    minutes: 55,
    seconds: 3,
  );

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining -= const Duration(seconds: 1));
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays.toString().padLeft(2, '0');
    final hours = (_remaining.inHours % 24).toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

   return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: IntrinsicHeight( // ✅ wrap Row with this
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ stretch children
        children: [
          // Left: label + timer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your BodyHoliday starts in:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _CountdownUnit(value: days, label: 'D'),
                      const SizedBox(width: 8),
                      _CountdownUnit(value: hours, label: 'H'),
                      const SizedBox(width: 8),
                      _CountdownUnit(value: minutes, label: 'M'),
                      const SizedBox(width: 8),
                      _CountdownUnit(value: seconds, label: 'S'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right: red arrow button - no fixed height needed
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 52,
              // ✅ height removed — stretches automatically
              decoration: const BoxDecoration(
                color: Color(0xFFE8414A),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003087),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003087),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GUEST MESSAGE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _GuestMessageCard extends StatelessWidget {
  const _GuestMessageCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/guest_avatar.jpg', // 🔁 replace with your asset
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Message text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dear Guest!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003087),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "We're looking forward to seeing you in beautiful Saint Lucia!",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

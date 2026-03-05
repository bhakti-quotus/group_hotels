import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/auth_controller.dart';
import 'package:get/get.dart';

class HeroBanner extends StatefulWidget {
  final Map<String, dynamic> bannerData;
  final List<String> images;
  final int currentImageIndex;
  final String logoUrl;

  const HeroBanner({
    Key? key,
    required this.bannerData,
    required this.images,
    required this.currentImageIndex,
    required this.logoUrl,
  }) : super(key: key);

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(60),
        bottomRight: Radius.circular(60),
      ),
      child: Stack(
        children: [
          // Animated background image with zoom effect
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.bannerData['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          // Gradient overlay
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          // Top bar with logo and user/login button
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Container(
                  child: Image.network(
                    widget.logoUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.business, color: AppColor.primary, size: 32),
                  ),
                ),
                // User icon or Login button
                Obx(() {
                  if (AuthController.to.isLoggedIn.value) {
                    return GestureDetector(
                      // onTap: () => Get.toNamed(AppRoutes.profile),
                      onTap: () {},
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 24,
                        child: Icon(
                          Icons.person,
                          color: AppColor.primary,
                          size: 28,
                        ),
                      ),
                    );
                  } else {
                    return ElevatedButton.icon(
                      onPressed: () => Get.toNamed('/login'),
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColor.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
          // Bottom content
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  widget.bannerData['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.bannerData['subtitle'] ?? '',
                  style: TextStyle(
                    color: AppColor.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Get.toNamed(widget.bannerData['cta']['route']),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bannerData['cta']['label'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Underline with left gap
                  Container(
                    margin: const EdgeInsets.only(left: 16), // GAP HERE
                    height: 2,
                    width: 55, // Set underline length
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

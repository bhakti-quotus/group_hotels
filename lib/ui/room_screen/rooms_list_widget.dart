import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/auth_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:group/ui/dialog/dialog.dart';
import 'package:get/get.dart';
import 'dart:async';

class RoomsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final Map<String, GlobalKey> roomKeys;
  final String? targetRoomId;
  final VoidCallback? onRefresh;
  final Color? primaryColor;

  const RoomsListWidget({
    required this.rooms,
    required this.roomKeys,
    this.targetRoomId,
    this.onRefresh,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return Container(
        color: AppColor.cardBackground,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 20),
              Text(
                'No Rooms Available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Check back later for updates',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              if (onRefresh != null)
                ElevatedButton(
                  onPressed: onRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor ?? AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColor.cardBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Room',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.text,
            ),
          ),
          const SizedBox(height: 16),
          ...rooms.map((room) => _buildRoomCard(room, context)),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room, BuildContext context) {
    final images = room['images'] as List? ?? [];
    final amenities = room['amenities'] as List? ?? [];
    final roomId = room['id'] as String;
    final isTargetRoom = roomId == targetRoomId;

    return Container(
      key: roomKeys[roomId],
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTargetRoom
              ? AppColor.primary.withOpacity(0.6)
              : AppColor.cardBorder,
          width: isTargetRoom ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isTargetRoom
                ? AppColor.primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            blurRadius: isTargetRoom ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image Carousel
          _ImageCarousel(images: images),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Name
                Text(
                  room['name'] ?? '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.text,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  room['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Max Occupancy
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 18,
                      color: AppColor.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Max ${room['maxOccupancy']} Guests',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Amenities
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.chipBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColor.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Price and Book Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'AED ${room['basePrice']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 3),
                              child: Text(
                                '/Night',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (AuthController.to.isLoggedIn.value) {
                          Get.toNamed(
                            AppRoutes.booking,
                            arguments: {'room': room},
                          );
                        } else {
                          showErrorDialog(
                            context,
                            'Please login to book a room',
                            onPressed: () {
                              Navigator.pop(context);
                              Get.toNamed(
                                AppRoutes.login,
                                arguments: {'nextRoute': AppRoutes.rooms},
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor ?? AppColor.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List images;

  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Start auto-scroll if there are multiple images
    if (widget.images.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isNotEmpty
        ? widget.images
        : ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Image PageView
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        // Dot Indicators (only show if more than one image)
        if (images.length > 1)
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

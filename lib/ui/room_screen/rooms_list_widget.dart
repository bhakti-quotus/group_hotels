import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:group/group/controllers/auth_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:group/ui/dialog/dialog.dart';
import 'package:get/get.dart';
import 'dart:async';

class RoomsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final int totalGuests;
  final String propertyCode;
  final String hotelName;
  final String propertyId;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Color? primaryColor;

  const RoomsListWidget({
    Key? key,
    required this.rooms,
    required this.totalGuests,
    required this.propertyCode,
    required this.hotelName,
    required this.propertyId,
    this.errorMessage,
    this.isLoading = false,
    this.onRefresh,
    this.primaryColor,
  }) : super(key: key);

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
          ...rooms.map((room) => _buildEnhancedRoomCard(room, context)),
        ],
      ),
    );
  }

  Widget _buildEnhancedRoomCard(
    Map<String, dynamic> room,
    BuildContext context,
  ) {
    final images = room['images'] as List? ?? [];
    final amenities = room['amenities'] as List? ?? [];
    final roomId = room['id']?.toString() ?? '';

    // Handle different key names for API vs mock
    final roomName = room['room_name'] ?? room['name'] ?? '';
    final roomType = room['room_type'] ?? room['type'] ?? '';
    final roomSize = room['room_size'] ?? 0;
    final roomUnit = room['room_unit'] ?? 'sq ft';
    final roomView = room['room_view'] ?? '';
    final maxOccupancy = room['max_occupancy'] ?? room['maxOccupancy'] ?? 0;
    final description = room['description'] ?? '';

    // For price, API has room_price array, mock has basePrice
    double basePrice = 0;
    String currencyCode = 'AED';
    if (room['room_price'] != null &&
        room['room_price'] is List &&
        room['room_price'].isNotEmpty) {
      double minPrice = double.infinity;
      for (final ratePlan in room['room_price']) {
        final baseByGuestAmts = ratePlan['baseByGuestAmts'] as List?;
        if (baseByGuestAmts != null && baseByGuestAmts.isNotEmpty) {
          final guestAmt = baseByGuestAmts.firstWhere(
            (amt) => (amt['numberOfGuests'] as int?) == totalGuests,
            orElse: () => baseByGuestAmts.last,
          );
          final price = (guestAmt['amountBeforeTax'] as num?)?.toDouble() ?? 0;
          if (price < minPrice) {
            minPrice = price;
            currencyCode = ratePlan['currencyCode'] ?? 'AED';
          }
        } else {
          final price = (ratePlan['totalAmount'] as num?)?.toDouble() ?? 0;
          if (price < minPrice) {
            minPrice = price;
            currencyCode = ratePlan['currencyCode'] ?? 'AED';
          }
        }
      }
      basePrice = minPrice == double.infinity ? 0 : minPrice;
    } else {
      basePrice = (room['basePrice'] as num?)?.toDouble() ?? 0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (primaryColor ?? AppColor.primary).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Content Section (Image + Details)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                Expanded(
                  flex: 6,
                  child: _EnhancedImageCarousel(
                    images: images,
                    primaryColor: primaryColor ?? AppColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                // Room Details
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room Name
                      Text(
                        roomName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.text,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Room Type Badge
                      if (roomType.toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (primaryColor ?? AppColor.primary).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            roomType.toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryColor ?? AppColor.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Description
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textLight,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 12),
                      // Room Features
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (roomSize > 0)
                            _FeatureItem(
                              icon: Icons.square_foot_rounded,
                              text: '$roomSize $roomUnit',
                              primaryColor: primaryColor ?? AppColor.primary,
                            ),
                          if (roomView.isNotEmpty)
                            _FeatureItem(
                              icon: Icons.landscape_rounded,
                              text: roomView,
                              primaryColor: primaryColor ?? AppColor.primary,
                            ),
                          _FeatureItem(
                            icon: Icons.people_rounded,
                            text: 'Up to $maxOccupancy guests',
                            primaryColor: primaryColor ?? AppColor.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Amenities Row
                      if (amenities.isNotEmpty)
                        _AmenitiesRow(
                          amenities: amenities.take(3).toList(),
                          primaryColor: primaryColor ?? AppColor.primary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
          // Book Now Button Section
          _BookNowSection(
            room: room,
            basePrice: basePrice,
            currencyCode: currencyCode,
            totalGuests: totalGuests,
            propertyCode: propertyCode,
            hotelName: hotelName,
            propertyId: propertyId,
            primaryColor: primaryColor ?? AppColor.primary,
          ),
        ],
      ),
    );
  }
}

class _EnhancedImageCarousel extends StatefulWidget {
  final List images;
  final Color primaryColor;

  const _EnhancedImageCarousel({
    required this.images,
    required this.primaryColor,
  });

  @override
  State<_EnhancedImageCarousel> createState() => _EnhancedImageCarouselState();
}

class _EnhancedImageCarouselState extends State<_EnhancedImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

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
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Handle both cases: images as list of strings or list of maps
    List<String> imageUrls = [];
    if (widget.images.isNotEmpty) {
      for (var item in widget.images) {
        if (item is String) {
          // Image is a string URL
          imageUrls.add(item);
        } else if (item is Map) {
          // Image is a map with 'url' key
          final url = item['url'];
          if (url != null) {
            imageUrls.add(url.toString());
          }
        }
      }
    }
    
    final images = imageUrls.isNotEmpty
        ? imageUrls
        : ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Image PageView
            SizedBox(
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
                    images[index].toString(),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: widget.primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),
            // Image Counter
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Dot Indicators
            if (images.length > 1)
              Positioned(
                bottom: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? widget.primaryColor
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color primaryColor;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AmenitiesRow extends StatelessWidget {
  final List amenities;
  final Color primaryColor;

  const _AmenitiesRow({
    required this.amenities,
    required this.primaryColor,
  });

  IconData _getAmenityIcon(String amenity) {
    final amenityStr = amenity.toLowerCase();
    if (amenityStr.contains('wifi')) return Icons.wifi;
    if (amenityStr.contains('ac') || amenityStr.contains('air')) return Icons.ac_unit;
    if (amenityStr.contains('tv')) return Icons.tv;
    if (amenityStr.contains('breakfast')) return Icons.free_breakfast;
    if (amenityStr.contains('parking')) return Icons.local_parking;
    if (amenityStr.contains('pool')) return Icons.pool;
    if (amenityStr.contains('gym')) return Icons.fitness_center;
    if (amenityStr.contains('spa')) return Icons.spa;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: amenities.map((amenity) {
        final amenityName = amenity['name'] ?? amenity.toString();
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getAmenityIcon(amenityName),
                size: 14,
                color: primaryColor,
              ),
              const SizedBox(width: 2),
              Text(
                amenityName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColor.textLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _BookNowSection extends StatelessWidget {
  final Map<String, dynamic> room;
  final double basePrice;
  final String currencyCode;
  final int totalGuests;
  final String propertyCode;
  final String hotelName;
  final String propertyId;
  final Color primaryColor;

  const _BookNowSection({
    required this.room,
    required this.basePrice,
    required this.currencyCode,
    required this.totalGuests,
    required this.propertyCode,
    required this.hotelName,
    required this.propertyId,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Starting from',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currencyCode ${basePrice.toInt()}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/night',
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
          // Book Now Button
          ElevatedButton(
            onPressed: () {
              Get.toNamed(
                '/room-details',
                arguments: {
                  'room': room,
                  'totalGuests': totalGuests,
                  'propertyCode': propertyCode,
                  'hotelName': hotelName,
                  'propertyId': propertyId,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


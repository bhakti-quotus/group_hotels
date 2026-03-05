import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:group/group/common/theme/theme.dart';
import '../../ui/room_screen/amenities_widget.dart';
import '../../ui/room_screen/gallery_widget.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  Map<String, dynamic> groupData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    BrandingColors.resetToDefaults();
    loadGroupData();
  }

  Future<void> loadGroupData() async {
    setState(() => _isLoading = true);
    final config = Get.find<HotelController>().getConfig();
    if (config != null && config['childHotels'] != null) {
      setState(() {
        groupData = config;
      });
    } else {
      // Load group data from assets
      try {
        final String response = await rootBundle.loadString(
          'assets/config.json',
        );
        final decoded = json.decode(response);
        final data = decoded;
        final groupConfig = data['config'] as Map<String, dynamic>? ?? {};
        BrandingColors.loadFromConfig(groupConfig);
        setState(() {
          groupData = data;
        });
      } catch (e) {
        print('Error loading data: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int getLowestPrice(List<dynamic> rooms) {
    if (rooms.isEmpty) return 0;
    int minPrice = rooms
        .map((r) => r['basePrice'] as int? ?? 0)
        .reduce((a, b) => a < b ? a : b);
    return minPrice;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelController>();
    final config = controller.getConfig();
    final branding =
        config?['config']?['branding'] as Map<String, dynamic>? ?? {};
    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    final childHotels = groupData['childHotels'] as List<dynamic>? ?? [];
    final groupConfig = groupData['config'] as Map<String, dynamic>? ?? {};
    final amenities = (groupConfig['amenities'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final gallery = (groupConfig['gallery']?['items'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(backgroundColor: AppColor.primary, elevation: 0),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading Hotels...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final fontFamily = branding['fontFamily'] as String? ?? 'Inter';

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: primaryColor, elevation: 0),
      ),
      body: childHotels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'No Hotels Available',
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
                  ElevatedButton(
                    onPressed: loadGroupData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
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
            )
          : RefreshIndicator(
              onRefresh: loadGroupData,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header with count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: childHotels.length == 1
                                      ? ''
                                      : 'Choose from ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    fontFamily: fontFamily,
                                  ),
                                ),

                                TextSpan(
                                  text: '${childHotels.length} ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontFamily: fontFamily,
                                  ),
                                ),

                                TextSpan(
                                  text: childHotels.length == 1
                                      ? 'Hotel'
                                      : 'Hotels',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hotel List
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: childHotels.length,
                      itemBuilder: (context, index) {
                        final hotel =
                            childHotels[index] as Map<String, dynamic>;
                        final hotelConfig =
                            hotel['config'] as Map<String, dynamic>? ?? {};
                        final hotelBranding =
                            hotelConfig['branding'] as Map<String, dynamic>? ??
                            {};
                        final rooms =
                            hotelConfig['rooms'] as List<dynamic>? ?? [];
                        final lowestPrice = getLowestPrice(rooms);
                        final hotelName = hotel['name'] ?? 'Unknown Hotel';
                        final contact =
                            hotelConfig['contact'] as Map<String, dynamic>? ??
                            {};
                        final address =
                            contact['address'] as String? ??
                            'No address available';
                        final splashImage =
                            hotelBranding['splashImage'] as String?;
                        final logo = hotelBranding['logo'] as String?;
                        final rating =
                            (hotel['rating'] as num?)?.toDouble() ?? 4.2;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hotel Image with Gradient Overlay
                              Stack(
                                children: [
                                  Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      image: splashImage != null
                                          ? DecorationImage(
                                              image: NetworkImage(splashImage),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: splashImage == null
                                          ? primaryColor.withOpacity(0.1)
                                          : null,
                                    ),
                                    child: splashImage == null
                                        ? Center(
                                            child: Icon(
                                              Icons.hotel,
                                              size: 60,
                                              color: primaryColor.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  // Gradient Overlay
                                  Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Price Tag
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'AED ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                                fontFamily: fontFamily,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '$lowestPrice',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                                fontFamily: fontFamily,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '/night',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontFamily: fontFamily,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Hotel Details
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (logo != null)
                                          Container(
                                            width: 80,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: NetworkImage(logo),
                                                fit: BoxFit.contain,
                                              ),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                hotelName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                  fontFamily: fontFamily,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on_outlined,
                                                    size: 14,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      address,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                        fontFamily: fontFamily,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // View Details Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.toNamed(
                                            AppRoutes.home,
                                            arguments: hotelConfig,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'View Details',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: fontFamily,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Amenities Section
                    if (amenities.isNotEmpty) ...[
                      AmenitiesWidget(
                        amenities: amenities,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Gallery Section
                    if (gallery.isNotEmpty) ...[
                      GalleryWidget(gallery: gallery),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

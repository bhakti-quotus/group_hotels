// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:group/group/controllers/hotel_controller.dart';
// import 'package:group/group/utils/app_routes.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:group/group/common/theme/theme.dart';
// import '../../ui/room_screen/amenities_widget.dart';
// import '../../ui/room_screen/gallery_widget.dart';

// class HotelScreen extends StatefulWidget {
//   const HotelScreen({super.key});

//   @override
//   State<HotelScreen> createState() => _HotelScreenState();
// }

// class _HotelScreenState extends State<HotelScreen> {
//   Map<String, dynamic> groupData = {};
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     BrandingColors.resetToDefaults();
//     loadGroupData();
//   }

//   Future<void> loadGroupData() async {
//     setState(() => _isLoading = true);
//     final config = Get.find<HotelController>().getConfig();
//     if (config != null && config['childHotels'] != null) {
//       setState(() {
//         groupData = config;
//       });
//     } else {
//       // Load group data from assets
//       try {
//         final String response = await rootBundle.loadString(
//           'assets/config.json',
//         );
//         final decoded = json.decode(response);
//         final data = decoded;
//         final groupConfig = data['config'] as Map<String, dynamic>? ?? {};
//         BrandingColors.loadFromConfig(groupConfig);
//         setState(() {
//           groupData = data;
//         });
//       } catch (e) {
//         print('Error loading data: $e');
//       }
//     }
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }

//   int getLowestPrice(List<dynamic> rooms) {
//     if (rooms.isEmpty) return 0;
//     int minPrice = rooms
//         .map((r) => r['basePrice'] as int? ?? 0)
//         .reduce((a, b) => a < b ? a : b);
//     return minPrice;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<HotelController>();
//     final config = controller.getConfig();
//     final branding =
//         config?['config']?['branding'] as Map<String, dynamic>? ?? {};
//     final primaryColor = branding['primaryColor'] != null
//         ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
//         : AppColor.primary;

//     final childHotels = groupData['childHotels'] as List<dynamic>? ?? [];
//     final groupConfig = groupData['config'] as Map<String, dynamic>? ?? {};
//     final amenities = (groupConfig['amenities'] as List<dynamic>? ?? [])
//         .map((e) => Map<String, dynamic>.from(e))
//         .toList();
//     final gallery = (groupConfig['gallery']?['items'] as List<dynamic>? ?? [])
//         .map((e) => Map<String, dynamic>.from(e))
//         .toList();

//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: AppColor.background,
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(0),
//           child: AppBar(backgroundColor: AppColor.primary, elevation: 0),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading Hotels...',
//                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final fontFamily = branding['fontFamily'] as String? ?? 'Inter';

//     return Scaffold(
//       backgroundColor: AppColor.background,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(0),
//         child: AppBar(backgroundColor: primaryColor, elevation: 0),
//       ),
//       body: childHotels.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.hotel_outlined, size: 80, color: Colors.grey[300]),
//                   const SizedBox(height: 20),
//                   Text(
//                     'No Hotels Available',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Check back later for updates',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: loadGroupData,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Refresh',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: loadGroupData,
//               color: primaryColor,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Column(
//                   children: [
//                     // Header with count
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 16,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text.rich(
//                             TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: childHotels.length == 1
//                                       ? ''
//                                       : 'Choose from ',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700],
//                                     fontFamily: fontFamily,
//                                   ),
//                                 ),

//                                 TextSpan(
//                                   text: '${childHotels.length} ',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: primaryColor,
//                                     fontFamily: fontFamily,
//                                   ),
//                                 ),

//                                 TextSpan(
//                                   text: childHotels.length == 1
//                                       ? 'Hotel'
//                                       : 'Hotels',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700],
//                                     fontFamily: fontFamily,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Hotel List
//                     ListView.builder(
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: childHotels.length,
//                       itemBuilder: (context, index) {
//                         final hotel =
//                             childHotels[index] as Map<String, dynamic>;
//                         final hotelConfig =
//                             hotel['config'] as Map<String, dynamic>? ?? {};
//                         final hotelBranding =
//                             hotelConfig['branding'] as Map<String, dynamic>? ??
//                             {};
//                         final rooms =
//                             hotelConfig['rooms'] as List<dynamic>? ?? [];
//                         final lowestPrice = getLowestPrice(rooms);
//                         final hotelName = hotel['name'] ?? 'Unknown Hotel';
//                         final contact =
//                             hotelConfig['contact'] as Map<String, dynamic>? ??
//                             {};
//                         final address =
//                             contact['address'] as String? ??
//                             'No address available';
//                         final splashImage =
//                             hotelBranding['splashImage'] as String?;
//                         final logo = hotelBranding['logo'] as String?;
//                         final rating =
//                             (hotel['rating'] as num?)?.toDouble() ?? 4.2;

//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.08),
//                                 blurRadius: 15,
//                                 offset: const Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Hotel Image with Gradient Overlay
//                               Stack(
//                                 children: [
//                                   Container(
//                                     height: 200,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(20),
//                                         topRight: Radius.circular(20),
//                                       ),
//                                       image: splashImage != null
//                                           ? DecorationImage(
//                                               image: NetworkImage(splashImage),
//                                               fit: BoxFit.cover,
//                                             )
//                                           : null,
//                                       color: splashImage == null
//                                           ? primaryColor.withOpacity(0.1)
//                                           : null,
//                                     ),
//                                     child: splashImage == null
//                                         ? Center(
//                                             child: Icon(
//                                               Icons.hotel,
//                                               size: 60,
//                                               color: primaryColor.withOpacity(
//                                                 0.3,
//                                               ),
//                                             ),
//                                           )
//                                         : null,
//                                   ),
//                                   // Gradient Overlay
//                                   Container(
//                                     height: 200,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(20),
//                                         topRight: Radius.circular(20),
//                                       ),
//                                       gradient: LinearGradient(
//                                         begin: Alignment.bottomCenter,
//                                         end: Alignment.topCenter,
//                                         colors: [
//                                           Colors.black.withOpacity(0.5),
//                                           Colors.transparent,
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   // Price Tag
//                                   Positioned(
//                                     top: 16,
//                                     right: 16,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 8,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(12),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black.withOpacity(
//                                               0.1,
//                                             ),
//                                             blurRadius: 5,
//                                           ),
//                                         ],
//                                       ),
//                                       child: Text.rich(
//                                         TextSpan(
//                                           children: [
//                                             TextSpan(
//                                               text: 'AED ',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: primaryColor,
//                                                 fontFamily: fontFamily,
//                                               ),
//                                             ),
//                                             TextSpan(
//                                               text: '$lowestPrice',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: primaryColor,
//                                                 fontFamily: fontFamily,
//                                               ),
//                                             ),
//                                             TextSpan(
//                                               text: '/night',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.grey[600],
//                                                 fontFamily: fontFamily,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               // Hotel Details
//                               Padding(
//                                 padding: const EdgeInsets.all(20),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         if (logo != null)
//                                           Container(
//                                             width: 80,
//                                             height: 60,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               image: DecorationImage(
//                                                 image: NetworkImage(logo),
//                                                 fit: BoxFit.contain,
//                                               ),
//                                               border: Border.all(
//                                                 color: Colors.grey[200]!,
//                                                 width: 1,
//                                               ),
//                                             ),
//                                           ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 hotelName,
//                                                 style: TextStyle(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.grey[800],
//                                                   fontFamily: fontFamily,
//                                                 ),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               const SizedBox(height: 6),
//                                               Row(
//                                                 children: [
//                                                   Icon(
//                                                     Icons.location_on_outlined,
//                                                     size: 14,
//                                                     color: Colors.grey[500],
//                                                   ),
//                                                   const SizedBox(width: 4),
//                                                   Expanded(
//                                                     child: Text(
//                                                       address,
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         color: Colors.grey[600],
//                                                         fontFamily: fontFamily,
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 20),
//                                     // View Details Button
//                                     SizedBox(
//                                       width: double.infinity,
//                                       height: 50,
//                                       child: ElevatedButton(
//                                         onPressed: () {
//                                           // Store the complete hotel data in HotelController
//                                           final hotelController = Get.find<HotelController>();
//                                           hotelController.setSelectedHotel(hotel);

//                                           // Navigate to home page
//                                           Get.toNamed(
//                                             AppRoutes.home,
//                                             arguments: hotelConfig,
//                                           );
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: primaryColor,
//                                           foregroundColor: Colors.white,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                           ),
//                                           elevation: 0,
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 24,
//                                           ),
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               'View Details',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontFamily: fontFamily,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Icon(Icons.arrow_forward, size: 20),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     // Amenities Section
//                     if (amenities.isNotEmpty) ...[
//                       AmenitiesWidget(
//                         amenities: amenities,
//                         primaryColor: primaryColor,
//                       ),
//                       const SizedBox(height: 12),
//                     ],

//                     // Gallery Section
//                     if (gallery.isNotEmpty) ...[
//                       GalleryWidget(gallery: gallery),
//                       const SizedBox(height: 12),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:group/group/controllers/hotel_controller.dart';
import 'package:group/group/utils/app_routes.dart';
import 'package:group/group/common/theme/theme.dart';

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

    // 1️⃣ Arguments passed via Get.toNamed
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final hasChildren = (args['childHotels'] as List?)?.isNotEmpty == true;
      if (hasChildren) {
        final rootArgs = args['config'] ?? args;
        BrandingColors.loadFromConfig(rootArgs);
        Get.find<HotelController>().setConfig(args, isRoot: true);
        if (mounted)
          setState(() {
            groupData = args;
            _isLoading = false;
          });
        return;
      }
    }

    // 2️⃣ Final fallback — assets/config.json
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      final decoded = json.decode(response) as Map<String, dynamic>;

      BrandingColors.loadFromConfig(
        decoded['config'] as Map<String, dynamic>? ?? {},
      );

      if (mounted)
        setState(() {
          groupData = decoded;
        });
      Get.find<HotelController>().setConfig(decoded, isRoot: true);
    } catch (e) {
      debugPrint('❌ Error loading config.json: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  int _lowestPrice(List<dynamic> rooms) {
    if (rooms.isEmpty) return 0;
    return rooms
        .map((r) => r['basePrice'] as int? ?? 0)
        .reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Group branding lives in groupData['config']['branding']
    final groupConfig = groupData['config'] as Map<String, dynamic>? ?? {};
    final branding = groupConfig['branding'] as Map<String, dynamic>? ?? {};

    final primaryColor = branding['primaryColor'] != null
        ? Color(int.parse(branding['primaryColor'].replaceFirst('#', '0xff')))
        : AppColor.primary;

    // ✅ childHotels is at ROOT level in your JSON
    final childHotels = groupData['childHotels'] as List<dynamic>? ?? [];
    final groupName = groupData['name'] as String? ?? 'Our Hotels';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.background,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, primaryColor.withOpacity(0.7)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Loading Properties...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (childHotels.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hotel_outlined,
                  size: 48,
                  color: primaryColor.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Properties Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColor.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for updates',
                style: TextStyle(fontSize: 14, color: AppColor.textLight),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: loadGroupData,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Refresh',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadGroupData,
        color: primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Collapsible header ────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              collapsedHeight: 60,
              pinned: true,
              backgroundColor: primaryColor,
              automaticallyImplyLeading: false,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light,
              ),
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final isCollapsed = constraints.maxHeight <= 62;
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              isCollapsed ? 0.2 : 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isCollapsed)
                        Expanded(
                          child: Text(
                            groupName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  );
                },
              ),
              titleSpacing: 16,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, primaryColor.withOpacity(0.85)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 2,
                                  color: AppColor.secondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'OUR PROPERTIES',
                                  style: TextStyle(
                                    color: AppColor.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              groupName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Count pill ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            size: 13,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${childHotels.length} ${childHotels.length == 1 ? 'Property' : 'Properties'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hotel cards ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final hotel = childHotels[index] as Map<String, dynamic>;
                  return _HotelCard(
                    hotel: hotel,
                    primaryColor: primaryColor,
                    lowestPrice: _lowestPrice(
                      hotel['config']?['rooms'] as List<dynamic>? ?? [],
                    ),
                  );
                }, childCount: childHotels.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── Hotel Card ───────────────────────────────────────────────────────────────

class _HotelCard extends StatefulWidget {
  final Map<String, dynamic> hotel;
  final Color primaryColor;
  final int lowestPrice;

  const _HotelCard({
    required this.hotel,
    required this.primaryColor,
    required this.lowestPrice,
  });

  @override
  State<_HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<_HotelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  /// Resolves hero image with 4 fallback sources.
  /// Your JSON structure: hotel.config.branding.splashImage
  ///                      hotel.config.home.sections[heroBanner].data.image
  ///                      hotel.config.rooms[0].images[0]
  ///                      hotel.config.gallery.items[0].url
  String? _resolveHeroImage(
    Map<String, dynamic> hotelConfig,
    Map<String, dynamic> hotelBranding,
    List<dynamic> rooms,
  ) {
    // 1️⃣ heroBanner section — proper hotel photo
    final sections = hotelConfig['home']?['sections'] as List<dynamic>?;
    final heroBannerImg =
        sections?.firstWhere(
              (s) => s['type'] == 'heroBanner',
              orElse: () => null,
            )?['data']?['image']
            as String?;
    if (heroBannerImg != null && heroBannerImg.trim().isNotEmpty) {
      return heroBannerImg.trim();
    }

    // 2️⃣ First room image
    if (rooms.isNotEmpty) {
      final imgs = rooms.first['images'] as List?;
      final roomImg = imgs?.isNotEmpty == true
          ? (imgs!.first as String?)?.trim()
          : null;
      if (roomImg != null && roomImg.isNotEmpty) return roomImg;
    }

    // 3️⃣ Gallery
    final galleryItems = hotelConfig['gallery']?['items'] as List<dynamic>?;
    final galleryImg = galleryItems?.isNotEmpty == true
        ? (galleryItems!.first['url'] as String?)?.trim()
        : null;
    if (galleryImg != null && galleryImg.isNotEmpty) return galleryImg;

    // 4️⃣ splashImage as last resort only
    final splash = (hotelBranding['splashImage'] as String?)?.trim();
    if (splash != null && splash.isNotEmpty) return splash;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hotelConfig = widget.hotel['config'] as Map<String, dynamic>? ?? {};
    final hotelBranding =
        hotelConfig['branding'] as Map<String, dynamic>? ?? {};
    final contact = hotelConfig['contact'] as Map<String, dynamic>? ?? {};
    final rooms = hotelConfig['rooms'] as List<dynamic>? ?? [];
    final amenities = hotelConfig['amenities'] as List<dynamic>? ?? [];
    final policies = hotelConfig['policies'] as Map<String, dynamic>? ?? {};

    final hotelName = widget.hotel['name'] as String? ?? 'Hotel';
    final address = contact['address'] as String? ?? 'Dubai, UAE';
    final logo = hotelBranding['logo'] as String?;
    final checkIn = policies['checkIn'] as String?;
    final checkOut = policies['checkOut'] as String?;

    // ✅ Use the proper multi-fallback resolver
    final heroImage = _resolveHeroImage(hotelConfig, hotelBranding, rooms);

    //debugPrint('🏨 Card[$hotelName] heroImage=$heroImage');

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.forward();
        final hotelController = Get.find<HotelController>();
        hotelController.setSelectedHotel(widget.hotel);
        hotelController.setConfig(widget.hotel['config']);
        BrandingColors.loadFromConfig(widget.hotel['config']);
        Get.toNamed(AppRoutes.home, arguments: widget.hotel);
      },
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Image ──────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: _HeroImage(
                      imageUrl: heroImage,
                      primaryColor: widget.primaryColor,
                      hotelName: hotelName,
                    ),
                  ),
                  // Gradient overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Room count badge
                  if (rooms.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${rooms.length} ${rooms.length == 1 ? 'Room Type' : 'Room Types'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Info section ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (logo != null && logo.isNotEmpty) ...[
                          _LogoWidget(logoUrl: logo),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            hotelName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColor.text,
                              letterSpacing: 0.1,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColor.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColor.textLight,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Check-in / Check-out
                    if (checkIn != null || checkOut != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.secondary.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (checkIn != null)
                            _PolicyChip(
                              icon: Icons.login_rounded,
                              label: 'Check-in',
                              value: checkIn,
                              color: widget.primaryColor,
                            ),
                          if (checkIn != null && checkOut != null)
                            const SizedBox(width: 10),
                          if (checkOut != null)
                            _PolicyChip(
                              icon: Icons.logout_rounded,
                              label: 'Check-out',
                              value: checkOut,
                              color: widget.primaryColor,
                            ),
                          const Spacer(),
                          if (amenities.isNotEmpty)
                            _PolicyChip(
                              icon: Icons.spa_outlined,
                              label: 'Amenities',
                              value: '${amenities.length}',
                              color: AppColor.secondary,
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.primaryColor,
                              widget.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore & Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Image Widget ────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String? imageUrl;
  final Color primaryColor;
  final String hotelName;

  const _HeroImage({
    required this.imageUrl,
    required this.primaryColor,
    required this.hotelName,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return _placeholder();

    return Image.network(
      imageUrl!,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          width: double.infinity,
          color: primaryColor.withOpacity(0.06),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Image failed [$hotelName]: $imageUrl\n$error');
        return _placeholder();
      },
    );
  }

  Widget _placeholder() => Container(
    height: 200,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withOpacity(0.12),
          primaryColor.withOpacity(0.06),
        ],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.hotel_rounded,
          size: 56,
          color: primaryColor.withOpacity(0.25),
        ),
        const SizedBox(height: 8),
        Text(
          'No Image Available',
          style: TextStyle(
            fontSize: 12,
            color: primaryColor.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─── Logo Widget ──────────────────────────────────────────────────────────────

class _LogoWidget extends StatelessWidget {
  final String logoUrl;
  const _LogoWidget({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Image.network(
        logoUrl,
        height: 28,
        width: 56,
        fit: BoxFit.contain,
        errorBuilder: (_, error, __) {
          debugPrint('❌ Logo failed: $logoUrl\n$error');
          return const SizedBox(width: 56, height: 28);
        },
      ),
    );
  }
}

// ─── Policy Chip ──────────────────────────────────────────────────────────────

class _PolicyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PolicyChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

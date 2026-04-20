import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'hero_banner.dart';
import 'description_section.dart';
import 'quick_actions_section.dart';
import 'featured_rooms_section.dart';
import 'featured_hotels_section.dart';
import 'gallery_preview_section.dart';
import '../facilities_page/facility_detail_page.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isGroupHome;

  const HomeScreen({super.key, required this.config, this.isGroupHome = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> homeData = {};
  Map<String, dynamic> aboutData = {};
  String logoUrl = '';
  int currentImageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showGreenStatusBar = false;

  @override
  void initState() {
    super.initState();

    // Print the ENTIRE config to see what we're working with
    // print('========== COMPLETE CONFIG ==========');
    //print(jsonEncode(widget.config));
    // print('=====================================');

    loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowGreen = _scrollController.offset > 20;
    if (shouldShowGreen != _showGreenStatusBar) {
      setState(() {
        _showGreenStatusBar = shouldShowGreen;
      });

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: _showGreenStatusBar
              ? AppColor.primary
              : Colors.transparent,
          statusBarIconBrightness: _showGreenStatusBar
              ? Brightness.light
              : Brightness.dark,
        ),
      );
    }
  }

  void loadData() {
    // print('========== LOADING DATA ==========');

    // Print all top-level keys in widget.config
    // print('Top-level keys in widget.config: ${widget.config.keys.toList()}');

    // Try to find about data in various possible locations
    Map<String, dynamic>? foundAboutData;

    // Location 1: Direct about key
    if (widget.config.containsKey('about')) {
      foundAboutData = widget.config['about'] as Map<String, dynamic>?;
      // print('Found about at top level: ${foundAboutData != null}');
    }

    // Location 2: Inside config key
    if (foundAboutData == null && widget.config.containsKey('config')) {
      final innerConfig = widget.config['config'] as Map<String, dynamic>?;
      //print('Inner config keys: ${innerConfig?.keys.toList()}');

      if (innerConfig != null && innerConfig.containsKey('about')) {
        foundAboutData = innerConfig['about'] as Map<String, dynamic>?;
        // print('Found about inside config key: ${foundAboutData != null}');
      }
    }

    // Location 3: Inside data key (sometimes used)
    if (foundAboutData == null && widget.config.containsKey('data')) {
      final data = widget.config['data'] as Map<String, dynamic>?;
      if (data != null && data.containsKey('about')) {
        foundAboutData = data['about'] as Map<String, dynamic>?;
        // print('Found about inside data key: ${foundAboutData != null}');
      }
    }

    setState(() {
      if (foundAboutData != null) {
        aboutData = foundAboutData;
        //print('✅ ABOUT DATA LOADED SUCCESSFULLY');
        // print('   Title: ${aboutData['title']}');
        // print(
        //   '   Description preview: ${aboutData['description']?.toString().substring(0, 50)}...',
        // );
      } else {
        // print('❌ COULD NOT FIND ABOUT DATA ANYWHERE');
        aboutData = {};
      }

      // Get home data
      if (widget.config.containsKey('config') &&
          widget.config['config'] != null) {
        final innerConfig = widget.config['config'] as Map<String, dynamic>;
        homeData = innerConfig['home'] ?? {};
        logoUrl = innerConfig['branding']?['logo'] ?? '';
      } else {
        homeData = widget.config['home'] ?? {};
        logoUrl = widget.config['branding']?['logo'] ?? '';
      }
    });

    // print('==================================');
  }

  Map<String, dynamic>? getSectionByType(String type) {
    final sections = homeData['sections'] as List?;
    if (sections == null) return null;

    try {
      return sections.firstWhere((section) => section['type'] == type);
    } catch (e) {
      return null;
    }
  }

  List<dynamic> _getQuickActionsItems(
    Map<String, dynamic>? quickActionsSection,
  ) {
    final items = quickActionsSection?['data']?['items'] as List<dynamic>?;
    if (items != null && items.isNotEmpty) {
      return items;
    }
    return [
      {
        'icon': 'meeting_room',
        'label': 'Promotions',
        'route': '/promotions',
        'color': '#0D5399',
      },
      {
        'icon': 'business',
        'label': 'Facilities',
        'route': '/facilities',
        'color': '#D67816',
      },
      {
        'icon': 'local_offer',
        'label': 'Offers',
        'route': '/promotions',
        'color': '#228B22',
      },
      {
        'icon': 'spa',
        'label': 'Amenities',
        'route': '/amenities',
        'color': '#800080',
      },
    ];
  }

  List<dynamic> _getOutletItems(Map<String, dynamic> config) {
    final directOutlets = config['outlets'] as List<dynamic>?;
    if (directOutlets != null && directOutlets.isNotEmpty) {
      return directOutlets;
    }

    final innerConfig = config['config'] as Map<String, dynamic>?;
    final nestedOutlets = innerConfig?['outlets'] as List<dynamic>?;
    return nestedOutlets ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // print('Building HomeScreen - aboutData isEmpty: ${aboutData.isEmpty}');

    final heroBanner = getSectionByType('heroBanner');
    final highlights = getSectionByType('highlights');
    final featuredRooms = getSectionByType('featuredRooms');
    final gallery = getSectionByType('galleryPreview');
    final quickActions = getSectionByType('quickActions');
    final childHotels = widget.config['childHotels'] as List<dynamic>?;

    if (heroBanner == null || heroBanner['data'] == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bannerData = heroBanner['data'];
    final images = gallery?['data']?['images'] as List? ?? [];
    final imagesList = images.cast<String>();
    final subtitle = bannerData['subtitle'] ?? 'Experience Luxury';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: _showGreenStatusBar
              ? AppColor.primary
              : Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: _showGreenStatusBar
                ? AppColor.primary
                : Colors.transparent,
            statusBarIconBrightness: _showGreenStatusBar
                ? Brightness.light
                : Brightness.dark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroBanner(
              bannerData: bannerData,
              images: imagesList,
              currentImageIndex: currentImageIndex,
              logoUrl: logoUrl,
            ),

            Container(
              decoration: const BoxDecoration(
                color: AppColor.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  if (aboutData.isNotEmpty)
                    DescriptionSection(
                      title: aboutData['title'] ?? 'About Us',
                      //subtitle: subtitle,
                      description:
                          aboutData['description'] ??
                          'Experience comfort, convenience, and thoughtful hospitality...',
                    )
                  else
                    // Show a message when about data is not found
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About section temporarily unavailable',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We are updating our information. Please check back later.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  if (!widget.isGroupHome) ...[
                    QuickActionsSection(
                      items: _getQuickActionsItems(quickActions),
                      onItemTap: (index, route) {
                        if (route.isNotEmpty) {
                          if (route == '/promotions') {
                            final innerConfig =
                                widget.config['config']
                                    as Map<String, dynamic>?;
                            final promotionsData =
                                innerConfig?['promotion'] as List<dynamic>? ??
                                [];
                            final hotelName =
                                widget.config['name'] as String? ??
                                'Promotions';
                            Get.toNamed(
                              '/promotions',
                              arguments: {
                                'promotions': promotionsData,
                                'title': hotelName,
                              },
                            );
                          } else if (route == '/facilities') {
                            final innerConfig =
                                widget.config['config']
                                    as Map<String, dynamic>?;
                            final facilitiesData =
                                innerConfig?['facility'] as List<dynamic>? ??
                                [];
                            final hotelName =
                                widget.config['name'] as String? ??
                                'Facilities';
                            Get.toNamed(
                              '/facilities',
                              arguments: {
                                'facilities': facilitiesData,
                                'title': hotelName,
                              },
                            );
                          } else if (route == '/meetings-events') {
                            final innerConfig =
                                widget.config['config']
                                    as Map<String, dynamic>?;
                            final facilitiesData =
                                innerConfig?['facility'] as List<dynamic>? ??
                                [];
                            if (facilitiesData.isNotEmpty) {
                              final firstFacility =
                                  facilitiesData[0] as Map<String, dynamic>;
                              Get.to(
                                () =>
                                    FacilityDetailPage(facility: firstFacility),
                              );
                            }
                          } else if (route == '/outlet') {
                            final items =
                                quickActions?['data']?['items']
                                    as List<dynamic>? ??
                                [];
                            final selectedItem =
                                (index >= 0 && index < items.length)
                                ? items[index] as Map<String, dynamic>
                                : <String, dynamic>{};
                            final outletItems = _getOutletItems(widget.config);
                            final hotelName =
                                widget.config['name'] as String? ??
                                'Royal Continental Hotel';
                            Get.toNamed(
                              route,
                              arguments: {
                                'outlets': outletItems,
                                'item': selectedItem,
                                'title':
                                    selectedItem['name'] as String? ??
                                    selectedItem['label'] as String? ??
                                    'Outlets',
                                'description':
                                    selectedItem['description'] as String? ??
                                    selectedItem['details']?['fullDescription']
                                        as String?,
                                'imageUrl': selectedItem['image'] as String?,
                                'hotelName': hotelName,
                              },
                            );
                          } else {
                            Get.toNamed(route);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (childHotels != null && childHotels.isNotEmpty)
                    FeaturedHotelsSection(hotels: childHotels)
                  else if (featuredRooms != null)
                    FeaturedRoomsSection(featuredRooms: featuredRooms),

                  if (imagesList.isNotEmpty)
                    GalleryPreviewSection(
                      images: imagesList,
                      currentImageIndex: currentImageIndex,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'dart:convert';
import 'hero_banner.dart';
import 'highlights_section.dart';
import 'description_section.dart';
import 'featured_rooms_section.dart';
import 'featured_hotels_section.dart';
import 'gallery_preview_section.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> config;

  const HomeScreen({Key? key, required this.config}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
   // print('Building HomeScreen - aboutData isEmpty: ${aboutData.isEmpty}');

    final heroBanner = getSectionByType('heroBanner');
    final highlights = getSectionByType('highlights');
    final featuredRooms = getSectionByType('featuredRooms');
    final gallery = getSectionByType('galleryPreview');
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

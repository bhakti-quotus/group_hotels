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
  String logoUrl = '';
  int currentImageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showGreenStatusBar = false;

  @override
  void initState() {
    super.initState();
    loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData(); // Reload data if config changed
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Change status bar color when scrolled past 200 pixels (adjust as needed)
    final shouldShowGreen = _scrollController.offset > 20;
    if (shouldShowGreen != _showGreenStatusBar) {
      setState(() {
        _showGreenStatusBar = shouldShowGreen;
      });

      // Update system UI overlay style
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
    setState(() {
      homeData =
          widget.config['config']?['home'] ?? widget.config['home'] ?? {};
      logoUrl =
          widget.config['config']?['branding']?['logo'] ??
          widget.config['branding']?['logo'] ??
          '';
    });
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
    print('Building HomeScreen - currentImageIndex: $currentImageIndex');

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
            // Hero Image Section
            HeroBanner(
              bannerData: bannerData,
              images: imagesList,
              currentImageIndex: currentImageIndex,
              logoUrl: logoUrl,
            ),

            // Content Section
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
                  // Popular Amenities
                  if (highlights != null)
                    HighlightsSection(highlights: highlights),

                  // Description
                  DescriptionSection(
                    subtitle:
                        bannerData['subtitle'] ??
                        'Experience luxury and comfort',
                  ),
                  const SizedBox(height: 24),

                  // Featured Hotels or Rooms
                  if (childHotels != null && childHotels.isNotEmpty)
                    FeaturedHotelsSection(hotels: childHotels)
                  else if (featuredRooms != null)
                    FeaturedRoomsSection(featuredRooms: featuredRooms),

                  // Gallery Preview
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

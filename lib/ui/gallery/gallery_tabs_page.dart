// gallery_tabs_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'gallery_grid_page.dart';

class GalleryTabsPage extends StatelessWidget {
  final Map<String, dynamic> groupConfig;
  final bool showTabs;

  const GalleryTabsPage({super.key, required this.groupConfig, this.showTabs = true});

  List<String> _extractImagesFromGallerySection(Map<String, dynamic>? section) {
    final images = <String>[];
    if (section == null) return images;
    
    try {
      final data = section['data'] as Map<String, dynamic>?;
      if (data != null) {
        final list = data['images'] as List<dynamic>? ?? [];
        for (final item in list) {
          if (item is String) {
            images.add(item);
          } else if (item is Map<String, dynamic>) {
            final url = item['url'] ?? item['image'];
            if (url is String && url.isNotEmpty) images.add(url);
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting gallery images: $e');
    }
    
    return images;
  }

  List<String> _imagesForHotel(Map<String, dynamic> hotel) {
    final images = <String>[];
    try {
      final innerConfig = hotel['config'] as Map<String, dynamic>? ?? hotel;

      // First, check for galleryPreview section in home
      final home = innerConfig['home'] as Map<String, dynamic>?;
      if (home != null) {
        final sections = home['sections'] as List<dynamic>? ?? [];
        for (final s in sections) {
          if (s is Map<String, dynamic> && s['type'] == 'galleryPreview') {
            final galleryImages = _extractImagesFromGallerySection(s);
            if (galleryImages.isNotEmpty) return galleryImages;
          }
        }
      }

      // Second, check for gallery.items
      final galleryItems = innerConfig['gallery']?['items'] as List<dynamic>?;
      if (galleryItems != null && galleryItems.isNotEmpty) {
        for (final it in galleryItems) {
          if (it is Map<String, dynamic>) {
            final url = it['url'] ?? it['image'] ?? it['images'];
            if (url is String && url.isNotEmpty) {
              images.add(url);
            }
          } else if (it is String && it.isNotEmpty) {
            images.add(it);
          }
        }
        if (images.isNotEmpty) return images;
      }

      // Third, check for top-level gallery list
      final topGallery = innerConfig['gallery'] as List<dynamic>?;
      if (topGallery != null) {
        for (final item in topGallery) {
          if (item is String && item.isNotEmpty) {
            images.add(item);
          }
        }
        if (images.isNotEmpty) return images;
      }

      // Fourth, check for images array directly
      final imagesArray = innerConfig['images'] as List<dynamic>?;
      if (imagesArray != null) {
        for (final item in imagesArray) {
          if (item is String && item.isNotEmpty) {
            images.add(item);
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting hotel images: $e');
    }
    
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final config = groupConfig['config'] as Map<String, dynamic>? ?? {};
    final homeSections = config['home']?['sections'] as List<dynamic>? ?? [];
    
    Map<String, dynamic>? gallerySection;
    for (final s in homeSections) {
      if (s is Map<String, dynamic> && s['type'] == 'galleryPreview') {
        gallerySection = s;
        break;
      }
    }

    final groupImages = _extractImagesFromGallerySection(gallerySection);
    final childHotels = groupConfig['childHotels'] as List<dynamic>? ?? [];

    // Collect images for "All" and per-child
    final List<String> allImages = List.from(groupImages);
    final List<List<String>> perHotelImages = [];

    for (final c in childHotels) {
      if (c is Map<String, dynamic>) {
        final images = _imagesForHotel(c);
        perHotelImages.add(images);
        allImages.addAll(images);
      }
    }

    // Remove duplicates (optional)
    final uniqueImages = allImages.toSet().toList();

    if (uniqueImages.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 16,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 3.5,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No images available',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If tabs are requested and there are child hotels, show tabs (All + each child)
    if (showTabs && childHotels.isNotEmpty) {
      final tabs = <Tab>[];
      final views = <Widget>[];

      // All tab
      tabs.add(const Tab(text: 'All'));
      views.add(GalleryGridPage(images: uniqueImages));

      // One tab per child hotel
      for (final c in childHotels) {
        if (c is Map<String, dynamic>) {
          final name = c['name'] as String? ?? c['title'] as String? ?? 'Hotel';
          final images = _imagesForHotel(c);
          tabs.add(Tab(text: name));
          views.add(GalleryGridPage(images: images));
        }
      }

      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 16,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 3.5,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Gallery',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            bottom: TabBar(
              isScrollable: true,
              tabs: tabs,
              labelColor: AppColor.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColor.primary,
            ),
          ),
          body: TabBarView(children: views),
        ),
      );
    }

    // Return single page with all images (no tabs)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 3.5,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gallery',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: GalleryGridPage(images: uniqueImages),
    );
  }
}
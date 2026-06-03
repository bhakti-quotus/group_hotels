// gallery_grid_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'gallery_fullscreen_page.dart';

class GalleryGridPage extends StatelessWidget {
  final List<String> images;

  const GalleryGridPage({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
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
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final url = images[index];
          return GestureDetector(
            onTap: () => Get.to(
              () => GalleryFullscreenPage(
                images: images,
                initialIndex: index,
              ),
              transition: Transition.fadeIn,
            ),
            child: Hero(
              tag: 'gallery_image_$index',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColor.primary.withOpacity(0.05),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppColor.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColor.primary.withOpacity(0.08),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Failed to load',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Fullscreen icon indicator
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.fullscreen_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Image counter badge (optional)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
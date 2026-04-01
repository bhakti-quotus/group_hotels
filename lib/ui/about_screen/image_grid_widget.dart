import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class ImageGridWidget extends StatelessWidget {
  final List<dynamic> images;
  final void Function(List<dynamic>, int) onImageTap;

  const ImageGridWidget({required this.images, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    final displayCount = images.length > 3 ? 3 : images.length;
    final remainingCount = images.length > 3 ? images.length - 3 : 0;

    return Container(
      color: AppColor.cardBackground,
      child: images.length == 1
          ? _buildSingleImage(images[0] as String, images, 0)
          : images.length == 2
          ? _buildTwoImages(images)
          : _buildThreeOrMoreImages(images, displayCount, remainingCount),
    );
  }

  Widget _buildSingleImage(String imageUrl, List<dynamic> images, int index) {
    return GestureDetector(
      onTap: () => onImageTap(images, index),
      child: ClipRRect(
        child: Image.network(
          imageUrl,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTwoImages(List<dynamic> images) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onImageTap(images, 0),
            child: ClipRRect(
              child: Image.network(
                images[0] as String,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onImageTap(images, 1),
            child: ClipRRect(
              child: Image.network(
                images[1] as String,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeOrMoreImages(
    List<dynamic> images,
    int displayCount,
    int remainingCount,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onImageTap(images, 0),
          child: ClipRRect(
            child: Image.network(
              images[0] as String,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onImageTap(images, 1),
                child: ClipRRect(
                  child: Image.network(
                    images[1] as String,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => onImageTap(images, 2),
                child: Stack(
                  children: [
                    ClipRRect(
                      child: Image.network(
                        images[2] as String,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (remainingCount > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: Center(
                            child: Text(
                              '+$remainingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

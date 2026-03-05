import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

class GalleryPreviewSection extends StatefulWidget {
  final List<String> images;
  final int currentImageIndex;

  const GalleryPreviewSection({
    Key? key,
    required this.images,
    required this.currentImageIndex,
  }) : super(key: key);

  @override
  State<GalleryPreviewSection> createState() => _GalleryPreviewSectionState();
}

class _GalleryPreviewSectionState extends State<GalleryPreviewSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GalleryPreviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentImageIndex != oldWidget.currentImageIndex) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.text,
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final isActive = widget.currentImageIndex == index;

              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Smooth movement like arrow animation
                  final curved = Curves.easeInOut.transform(
                    _animationController.value,
                  );
                  final offsetX = isActive ? curved * 8 : 0.0; // Move 8px

                  return Transform.translate(
                    offset: Offset(offsetX, 0.0),
                    child: child,
                  );
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border.all(color: AppColor.secondary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

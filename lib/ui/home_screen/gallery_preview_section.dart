import 'package:flutter/material.dart';
import 'package:sunswept/group/common/theme/theme.dart';

class GalleryPreviewSection extends StatefulWidget {
  final List<String> images;
  final int currentImageIndex;

  /// Optional: pass full gallery items from config for captions
  /// Each item: { 'url': String, 'caption': String, 'type': String }
  final List<Map<String, dynamic>>? galleryItems;

  const GalleryPreviewSection({
    Key? key,
    required this.images,
    required this.currentImageIndex,
    this.galleryItems,
  }) : super(key: key);

  @override
  State<GalleryPreviewSection> createState() => _GalleryPreviewSectionState();
}

class _GalleryPreviewSectionState extends State<GalleryPreviewSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _getCaptionAt(int index) {
    if (widget.galleryItems != null && index < widget.galleryItems!.length) {
      return widget.galleryItems![index]['caption'] as String?;
    }
    return null;
  }

  void _openFullscreen(BuildContext context, int startIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FullscreenGallery(
          images: widget.images,
          galleryItems: widget.galleryItems,
          initialIndex: startIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 20, height: 2, color: AppColor.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'GALLERY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.secondary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Our Spaces',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColor.text,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _openFullscreen(context, _selectedIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Featured large image
        GestureDetector(
          onTap: () => _openFullscreen(context, _selectedIndex),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Stack(
              key: ValueKey(_selectedIndex),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.images[_selectedIndex],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                ),
                // Dark gradient bottom for caption
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Caption overlay
                if (_getCaptionAt(_selectedIndex) != null)
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColor.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getCaptionAt(_selectedIndex)!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Fullscreen icon
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Thumbnail strip
        SizedBox(
          height: 68,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: isSelected ? 90 : 72,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.secondary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColor.secondary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey.shade200),
                        ),
                        if (!isSelected)
                          Container(color: Colors.black.withOpacity(0.2)),
                      ],
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

// ─── Fullscreen Gallery Overlay ───────────────────────────────────────────────

class _FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final List<Map<String, dynamic>>? galleryItems;
  final int initialIndex;

  const _FullscreenGallery({
    required this.images,
    required this.initialIndex,
    this.galleryItems,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String? _getCaptionAt(int index) {
    if (widget.galleryItems != null && index < widget.galleryItems!.length) {
      return widget.galleryItems![index]['caption'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) => InteractiveViewer(
              child: Center(
                child: Image.network(widget.images[index], fit: BoxFit.contain),
              ),
            ),
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom caption
          if (_getCaptionAt(_currentIndex) != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  top: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColor.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getCaptionAt(_currentIndex)!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Dot indicators
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (i) {
                final isActive = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColor.secondary : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

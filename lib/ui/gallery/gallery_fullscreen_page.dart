import 'package:flutter/material.dart';

class GalleryFullscreenPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryFullscreenPage({super.key, required this.images, this.initialIndex = 0});

  @override
  State<GalleryFullscreenPage> createState() => _GalleryFullscreenPageState();
}

class _GalleryFullscreenPageState extends State<GalleryFullscreenPage> {
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
                child: Image.network(widget.images[index], fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SingleImageFullscreenPage extends StatelessWidget {
  final String imageUrl;

  const SingleImageFullscreenPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

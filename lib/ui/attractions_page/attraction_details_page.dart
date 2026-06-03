// attraction_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class AttractionDetailsPage extends StatefulWidget {
  const AttractionDetailsPage({super.key});

  @override
  State<AttractionDetailsPage> createState() => _AttractionDetailsPageState();
}

class _AttractionDetailsPageState extends State<AttractionDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showPrimaryAppBar = false;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoInitialized = false;
  bool _videoInitializing = false;
  bool _videoError = false;

  Map<String, dynamic> get _args => Get.arguments as Map<String, dynamic>? ?? {};
  String get _videoUrl => _args['video'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (_videoUrl.isNotEmpty) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 20;
    if (shouldShow != _showPrimaryAppBar) {
      setState(() => _showPrimaryAppBar = shouldShow);
    }
  }

  Future<void> _initVideo() async {
    if (_videoInitializing || _videoInitialized) return;
    final url = _videoUrl;
    if (url.isEmpty) return;

    setState(() {
      _videoInitializing = true;
      _videoError = false;
    });

    try {
      final uri = Uri.tryParse(url);
      if (uri == null) throw 'Invalid video URL';

      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        autoInitialize: true,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColor.primary,
          handleColor: AppColor.primary,
          backgroundColor: Colors.white24,
          bufferedColor: AppColor.primary.withOpacity(0.4),
        ),
        errorBuilder: (_, __) => _buildVideoError(),
      );

      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _videoInitialized = true;
        _videoInitializing = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _videoInitializing = false;
          _videoError = true;
        });
      }
    }
  }

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      color: AppColor.primary.withOpacity(0.10),
      child: Center(
        child: loading
            ? CircularProgressIndicator(color: AppColor.primary)
            : Icon(
                Icons.place_outlined,
                size: 64,
                color: AppColor.primary.withOpacity(0.4),
              ),
      ),
    );
  }

  Widget _buildVideoSection() {
    if (_videoUrl.isEmpty) return const SizedBox.shrink();

    if (_videoInitializing) {
      return Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_videoError) {
      return Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
              const SizedBox(height: 8),
              const Text('Unable to load video'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _initVideo,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_videoInitialized && _chewieController != null && _videoController != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _args['name'] as String? ?? 'Attraction';
    final image = _args['image'] as String? ?? '';
    final description = _args['description'] as String? ?? '';
    final location = _args['location'] as String? ?? '';
    final phone = _args['phone'] as String? ?? _args['telephone'] as String? ?? '';
    final email = _args['email'] as String? ?? '';
    final website = _args['website'] as String? ?? _args['url'] as String? ?? '';
    final rating = _args['rating'] as String? ?? '4.5';
    final openingHours = _args['opening_hours'] as String? ?? '';

    final List<_InfoItem> infoItems = [
      if (location.isNotEmpty)
        _InfoItem(Icons.place_outlined, 'Location', location, false),
      if (openingHours.isNotEmpty)
        _InfoItem(Icons.access_time_outlined, 'Opening Hours', openingHours, false),
      if (phone.isNotEmpty)
        _InfoItem(Icons.phone_outlined, 'Phone', phone, true),
      if (email.isNotEmpty)
        _InfoItem(Icons.email_outlined, 'Email', email, true),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero App Bar ──
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor:
                _showPrimaryAppBar ? AppColor.primary : Colors.transparent,
            elevation: _showPrimaryAppBar ? 4 : 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _showPrimaryAppBar
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _buildImagePlaceholder(loading: true);
                          },
                        )
                      : _buildImagePlaceholder(),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.28),
                          Colors.transparent,
                          Colors.black.withOpacity(0.82),
                        ],
                      ),
                    ),
                  ),

                  // Rating badge
                  // Positioned(
                  //   top: 60,
                  //   right: 20,
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //     decoration: BoxDecoration(
                  //       color: Colors.black.withOpacity(0.6),
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.star, size: 14, color: Colors.amber[400]),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           rating,
                  //           style: const TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 13,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Name + accent bar
                  Positioned(
                    bottom: 28,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColor.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -·- motif
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 32,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Discover This Amazing Place',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.75,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],

                  // Video section
                  if (_videoUrl.isNotEmpty) _buildVideoSection(),

                  // Info card
                  if (infoItems.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildInfoCard(infoItems),
                  ],

                  // Website button
                  if (website.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(website),
                        icon: const Icon(Icons.language, size: 18),
                        label: const Text(
                          'Visit Website',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return _InfoRow(
            item: item,
            isLast: isLast,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: item.value));
              Get.snackbar(
                '${item.label} copied',
                item.value,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildVideoError() {
    return Container(
      color: AppColor.primary.withOpacity(0.08),
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Video cannot be played'),
      ),
    );
  }
}

// ── Info Row ──
class _InfoRow extends StatelessWidget {
  final _InfoItem item;
  final bool isLast;
  final VoidCallback onCopy;

  const _InfoRow({
    required this.item,
    required this.isLast,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 19, color: AppColor.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary.withOpacity(0.75),
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.copyable)
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppColor.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade100,
            ),
          ),
      ],
    );
  }
}

// ── Data class ──
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const _InfoItem(this.icon, this.label, this.value, this.copyable);
}
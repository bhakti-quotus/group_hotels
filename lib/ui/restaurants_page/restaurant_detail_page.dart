import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showPrimaryAppBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 20;
    if (shouldShow != _showPrimaryAppBar) {
      setState(() => _showPrimaryAppBar = shouldShow);
    }
  }

  void _copyToClipboard(String value, String label) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar(
      '$label copied',
      value,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      color: AppColor.primary.withOpacity(0.10),
      child: Center(
        child: loading
            ? CircularProgressIndicator(color: AppColor.primary)
            : Icon(
                Icons.restaurant_menu_outlined,
                size: 64,
                color: AppColor.primary.withOpacity(0.4),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final name = restaurant['name'] as String? ?? 'Restaurant';
    final imageUrl = restaurant['image'] as String? ?? '';
    final description = restaurant['description'] as String? ?? '';
    final location = restaurant['location'] as String? ?? '';
    final fromDay =
        restaurant['from-day'] as String? ?? restaurant['fromDay'] as String? ?? '';
    final toDay =
        restaurant['to-day'] as String? ?? restaurant['toDay'] as String? ?? '';
    final fromTime =
        restaurant['from-time'] as String? ?? restaurant['fromTime'] as String? ?? '';
    final toTime =
        restaurant['to-time'] as String? ?? restaurant['toTime'] as String? ?? '';
    final number =
        restaurant['number'] as String? ?? restaurant['phone'] as String? ?? '';
    final email = restaurant['email'] as String? ?? '';

    final dayRange = (fromDay.isNotEmpty || toDay.isNotEmpty)
        ? [fromDay, toDay].where((v) => v.isNotEmpty).join(' – ')
        : '';
    final timeRange = (fromTime.isNotEmpty || toTime.isNotEmpty)
        ? [fromTime, toTime].where((v) => v.isNotEmpty).join(' – ')
        : '';

    final List<_InfoItem> infoItems = [
      if (location.isNotEmpty)
        _InfoItem(Icons.place_outlined, 'Location', location, false),
      if (dayRange.isNotEmpty)
        _InfoItem(Icons.calendar_today_outlined, 'Open Days', dayRange, false),
      if (timeRange.isNotEmpty)
        _InfoItem(Icons.schedule_outlined, 'Open Hours', timeRange, false),
      if (number.isNotEmpty)
        _InfoItem(Icons.phone_outlined, 'Phone', number, true),
      if (email.isNotEmpty)
        _InfoItem(Icons.email_outlined, 'Email', email, true),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
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
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(),
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

          // ── Body ─────────────────────────────────────────────────────
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
                    'Explore Our Dining & Nightlife',
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

                  if (infoItems.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildInfoCard(infoItems),
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
            onCopy: () => _copyToClipboard(item.value, item.label),
          );
        }),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

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
              // Icon badge
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

              // Label + value
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

              // Copy button — only for copyable fields
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

// ── Data class ────────────────────────────────────────────────────────────────

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const _InfoItem(this.icon, this.label, this.value, this.copyable);
}
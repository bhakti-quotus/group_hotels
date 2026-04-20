import 'dart:ui';
import './pdf_viewer_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';

class FacilityDetailPage extends StatelessWidget {
  final Map<String, dynamic> facility;

  const FacilityDetailPage({super.key, required this.facility});

  void _copyPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text('Phone number copied'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the video link.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _sectionHeading(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.secondary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = facility['name'] as String? ?? '';
    final heading = facility['heading'] as String? ?? '';
    final description = facility['description'] as String? ?? '';
    final imageUrl = facility['image'] as String? ?? '';
    final details = facility['details'] as Map<String, dynamic>? ?? {};
    final type = facility['type'] as String? ?? '';

    String? spaRateCardUrl;
    if ((details['rate-cardPdfUrl'] as String?)?.isNotEmpty ?? false) {
      spaRateCardUrl = details['rate-cardPdfUrl'] as String;
    } else if (details['services'] != null) {
      final services = details['services'] as List;
      final serviceWithRateCard = services
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (service) =>
                (service['rate-cardPdfUrl'] as String?)?.isNotEmpty ?? false,
            orElse: () => <String, dynamic>{},
          );
      if (serviceWithRateCard.isNotEmpty) {
        spaRateCardUrl = serviceWithRateCard['rate-cardPdfUrl'] as String?;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColor.primary,
            elevation: 0,
            scrolledUnderElevation: 4,
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            foregroundColor: Colors.white,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Decorative line
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    heading,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondary,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade100, thickness: 1),
                  const SizedBox(height: 6),

                  if (details['fullDescription'] != null ||
                      details['description'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      (details['fullDescription'] ?? details['description'])
                              as String? ??
                          '',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],

                  // Contact Section
                  if ((details['wpNumber'] != null &&
                          (details['wpNumber'] as String).isNotEmpty) ||
                      (details['phone'] != null &&
                          (details['phone'] as String).isNotEmpty)) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Contact Information'),
                    const SizedBox(height: 16),
                    if (details['wpNumber'] != null &&
                        (details['wpNumber'] as String).isNotEmpty) ...[
                      _buildSimpleContactCard(
                        icon: Icons.chat,
                        iconColor: const Color(0xFF25D366),
                        title: 'WhatsApp',
                        value: details['wpNumber'] as String,
                        onCopy: () => _copyPhoneNumber(
                          context,
                          details['wpNumber'] as String,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (details['phone'] != null &&
                        (details['phone'] as String).isNotEmpty)
                      _buildSimpleContactCard(
                        icon: Icons.phone_outlined,
                        iconColor: AppColor.primary,
                        title: 'Call Now',
                        value: details['phone'] as String,
                        onCopy: () => _copyPhoneNumber(
                          context,
                          details['phone'] as String,
                        ),
                      ),
                  ],

                  // Locations for meeting rooms
                  if (type == 'meeting_room' &&
                      details['locations'] != null) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Our Locations'),
                    const SizedBox(height: 16),
                    ...(details['locations'] as List).map((loc) {
                      return _buildLocationCardWithPhoto(
                        loc as Map<String, dynamic>,
                      );
                    }).toList(),
                  ],

                  // Services for spa
                  if (type == 'spa' && details['services'] != null) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Our Services'),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (details['services'] as List).length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.88,
                          ),
                      itemBuilder: (context, index) {
                        final service =
                            (details['services'] as List)[index]
                                as Map<String, dynamic>;
                        return _buildServiceCard(context, service);
                      },
                    ),
                  if ((spaRateCardUrl != null && spaRateCardUrl.isNotEmpty) ||
    ((details['youtubeUrl'] as String?)?.isNotEmpty == true)) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (spaRateCardUrl != null &&
                                spaRateCardUrl.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => PdfViewerPage(url: spaRateCardUrl!),
                                  );
                                },
                                icon: const Icon(Icons.menu_book, size: 18),
                                label: const Text('View Rate Card'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            if ((details['youtubeUrl'] as String?)
                                    ?.isNotEmpty ??
                                false )
                              ElevatedButton.icon(
                                onPressed: () {
                                  final youtubeUrl =
                                      (details['youtubeUrl'] as String?)
                                              ?.isNotEmpty ==
                                          true
                                      ? details['youtubeUrl'] as String
                                      : details['youtube'] as String;
                                  _openExternalUrl(context, youtubeUrl);
                                },
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  size: 18,
                                ),
                                label: const Text('Watch Video'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  // Facilities
                  if (details['facilities'] != null) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Facilities & Amenities'),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth =
                            (constraints.maxWidth - 30) /
                            4; // 4 columns tight spacing
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: (details['facilities'] as List).map((fac) {
                            final f = fac as Map<String, dynamic>;
                            return SizedBox(
                              width: itemWidth,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColor.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: _buildFacilityIcon(
                                        f['icon'] as String? ?? '',
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    f['name'] as String? ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.secondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],

                  // Gallery
                  if (details['photos'] != null &&
                      (details['photos'] as List).isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Gallery'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: (details['photos'] as List).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final photos = (details['photos'] as List)
                              .cast<String>();
                          final photoUrl = photos[index];
                          return GestureDetector(
                            onTap: () => Get.to(
                              () => _FullScreenGallery(
                                photos: photos,
                                initialIndex: index,
                              ),
                              transition: Transition.fadeIn,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                photoUrl,
                                width: 160,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 160,
                                  height: 120,
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Menu button
                  if ((type == 'restaurant' || type == 'cafe') &&
                      details['menuPdfUrl'] != null &&
                      (details['menuPdfUrl'] as String).isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColor.primary.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final menuUrl = details['menuPdfUrl'] as String;
                          Get.to(() => PdfViewerPage(url: menuUrl));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 18,
                              color: AppColor.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'View Full Menu',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: AppColor.primary,
                            ),
                          ],
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

  Widget _buildSimpleContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.copy_outlined, size: 16, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCardWithPhoto(Map<String, dynamic> location) {
    final photos = location['photos'] as List<dynamic>? ?? [];
    final firstPhoto = photos.isNotEmpty ? photos[0] as String : null;
    final name = location['name'] as String? ?? '';
    final locationText = location['location'] as String? ?? '';
    final sqm = location['sqm'] as String? ?? '';

    return GestureDetector(
      onTap: () => Get.to(
        () => _LocationDetailPage(location: location),
        transition: Transition.rightToLeft,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Image
              SizedBox(
                width: 130,
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    firstPhoto != null
                        ? Image.network(
                            firstPhoto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColor.primary.withOpacity(0.1),
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 36,
                                  color: AppColor.primary.withOpacity(0.5),
                                ),
                              ),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: AppColor.primary.withOpacity(0.1),
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColor.primary.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 36,
                                color: AppColor.primary.withOpacity(0.5),
                              ),
                            ),
                          ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColor.primary,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.aspect_ratio,
                            color: AppColor.primary,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Area: $sqm',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColor.secondary.withOpacity(0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.secondary.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(
                                      color: AppColor.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 9,
                                    color: AppColor.secondary,
                                  ),
                                ],
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
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final imageUrl = service['image'] as String?;
    return Container(
      //margin: const EdgeInsets.only(bottom: 6),
     padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service['name'] as String? ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey[100],
                  child: Icon(Icons.image_outlined, color: Colors.grey[400]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      color: AppColor.primary.withOpacity(0.1),
      child: Center(
        child: loading
            ? CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              )
            : Icon(Icons.image_outlined, color: Colors.grey[300], size: 56),
      ),
    );
  }
}

// ─── Location Detail Page ───────────────────────────────────────────────────

class _LocationDetailPage extends StatelessWidget {
  final Map<String, dynamic> location;

  const _LocationDetailPage({required this.location});

  void _copyPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text('Phone number copied'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.secondary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = location['name'] as String? ?? '';
    final locationText = location['location'] as String? ?? '';
    final sqm = location['sqm'] as String? ?? '';
    final description = location['description'] as String? ?? '';
    final wpNumber = location['wpNumber'] as String? ?? '';
    final callNumber = location['callNumber'] as String? ?? '';
    final photos = location['photos'] as List<dynamic>? ?? [];
    final facilities = location['facilities'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColor.secondary,
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: AppColor.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Photo
                  if (photos.isNotEmpty)
                    GestureDetector(
                      onTap: () => Get.to(
                        () => _FullScreenGallery(
                          photos: photos.cast<String>(),
                          initialIndex: 0,
                        ),
                        transition: Transition.fadeIn,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          photos[0] as String,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: AppColor.primary.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 50,
                                color: AppColor.primary.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Location info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColor.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColor.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                locationText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.aspect_ratio,
                              color: AppColor.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Area: $sqm',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColor.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // About
                  _sectionHeading('About'),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),

                  // Contact
                  if (wpNumber.isNotEmpty || callNumber.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Contact'),
                    const SizedBox(height: 16),
                    if (wpNumber.isNotEmpty)
                      _buildContactCard(
                        icon: Icons.chat,
                        iconColor: const Color(0xFF25D366),
                        title: 'WhatsApp',
                        value: wpNumber,
                        onCopy: () => _copyPhoneNumber(context, wpNumber),
                      ),
                    if (callNumber.isNotEmpty) ...[
                      if (wpNumber.isNotEmpty) const SizedBox(height: 12),
                      _buildContactCard(
                        icon: Icons.phone_outlined,
                        iconColor: AppColor.primary,
                        title: 'Call Now',
                        value: callNumber,
                        onCopy: () => _copyPhoneNumber(context, callNumber),
                      ),
                    ],
                  ],

                  // Gallery
                  if (photos.length > 1) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Gallery'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final photoUrl = photos[index] as String;
                          return GestureDetector(
                            onTap: () => Get.to(
                              () => _FullScreenGallery(
                                photos: photos.cast<String>(),
                                initialIndex: index,
                              ),
                              transition: Transition.fadeIn,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                photoUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey[400],
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Facilities
                  if (facilities.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _sectionHeading('Facilities'),
                    const SizedBox(height: 16),
                    ...facilities.map((fac) {
                      final f = fac as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),

                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColor.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _buildFacilityIcon(
                                  f['icon'] as String? ?? '',
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                f['name'] as String? ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.copy_outlined, size: 16, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full Screen Gallery ────────────────────────────────────────────────────

class _FullScreenGallery extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _FullScreenGallery({required this.photos, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.photos[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white38,
                      size: 60,
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (widget.photos.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.photos.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColor.primary
                          : Colors.white.withOpacity(0.4),
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

// ─── Helpers ────────────────────────────────────────────────────────────────

IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'meeting_room':
      return Icons.meeting_room;
    case 'wifi':
      return Icons.wifi;
    case 'videocam':
      return Icons.videocam;
    case 'restaurant':
      return Icons.restaurant;
    case 'menu_book':
      return Icons.menu_book;
    case 'coffee':
      return Icons.coffee;
    case 'pool':
      return Icons.pool;
    case 'fitness_center':
      return Icons.fitness_center;
    case 'local_cafe':
      return Icons.local_cafe;
    case 'spa':
      return Icons.spa;
    case 'print':
      return Icons.print;
    case 'free_breakfast':
      return Icons.free_breakfast;
    case 'business':
      return Icons.business;
    case 'catering':
      return Icons.restaurant;
    case 'event':
      return Icons.event;
    case 'weekend':
      return Icons.weekend;
    case 'parking':
      return Icons.local_parking;
    case 'ac':
      return Icons.ac_unit;
    case 'projector':
      return Icons.videocam;
    case 'sound':
      return Icons.speaker;
    default:
      return Icons.star;
  }
}

Widget _buildFacilityIcon(String icon, {double size = 24}) {
  final normalized = icon.trim();
  if (normalized.isEmpty) {
    return Icon(Icons.star, color: AppColor.primary, size: size);
  }
  final lower = normalized.toLowerCase();
  if (lower.endsWith('.svg')) {
    return SvgPicture.network(
      normalized,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (context) =>
          Icon(Icons.image_not_supported, size: size, color: AppColor.primary),
    );
  }
  if (lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg')) {
    return Image.network(
      normalized,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.image_not_supported, size: size, color: AppColor.primary),
    );
  }
  return Icon(_getIconData(normalized), color: AppColor.primary, size: size);
}

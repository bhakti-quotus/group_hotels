// offer_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'offer_detail_page.dart';

class OfferListPage extends StatelessWidget {
  final List<dynamic>? offers;
  final String? title;

  const OfferListPage({super.key, required this.offers, this.title});

  @override
  Widget build(BuildContext context) {
    final offerItems = offers ?? [];
    final pageTitle = 'Offers';
    final hotelName = title ?? 'Royal Continental Hotel';

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
        titleSpacing: 5,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Offers",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hotelName,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: offerItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 56,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No offers available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Hero heading section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exclusive offers & packages tailored for you',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Decorative motif
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
                      ],
                    ),
                  ),
                ),
                // Offer cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final offer = offerItems[index] as Map<String, dynamic>;
                        final name = offer['name'] as String? ?? 'Offer';
                        final location = offer['location'] as String? ?? '';
                        final imageUrl = offer['image'] as String? ?? '';
                        final discount = offer['discount'] as String? ?? '';
                        final validTill = offer['valid_till'] as String? ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _OfferCard(
                            name: name,
                            location: location,
                            imageUrl: imageUrl,
                            discount: discount,
                            validTill: validTill,
                            onTap: () => Get.to(
                              () => OfferDetailPage(offer: offer),
                              transition: Transition.rightToLeft,
                            ),
                          ),
                        );
                      },
                      childCount: offerItems.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
    );
  }
}

// Offer Card Widget
class _OfferCard extends StatelessWidget {
  final String name;
  final String location;
  final String imageUrl;
  final String discount;
  final String validTill;
  final VoidCallback onTap;

  const _OfferCard({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.discount,
    required this.validTill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = location.trim().isNotEmpty;
    final hasDiscount = discount.trim().isNotEmpty;
    final hasValidTill = validTill.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with discount badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColor.secondary, AppColor.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Valid till badge
                  if (hasValidTill)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Valid till $validTill',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Offer name overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  if (hasLocation)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColor.primary.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (hasLocation) const SizedBox(height: 12),
                  // Bottom row with decorative elements and CTA
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 35,
                        height: 1.5,
                        color: AppColor.primary.withOpacity(0.3),
                      ),
                      const Spacer(),
                      // View Details button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      color: AppColor.primary.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.local_offer_outlined,
          size: 48,
          color: AppColor.primary.withOpacity(0.35),
        ),
      ),
    );
  }
}
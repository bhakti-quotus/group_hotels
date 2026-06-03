// attractions_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'attraction_details_page.dart';

class AttractionsListPage extends StatelessWidget {
  final List<dynamic> attractions;
  final String? title;

  const AttractionsListPage({super.key, required this.attractions, this.title});

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  "Attractions",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title ?? 'Discover nearby attractions',
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
      body: attractions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.place_outlined, size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No attractions available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore popular attractions around our properties',
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
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final attr = attractions[index] as Map<String, dynamic>;
                        final name = attr['name'] as String? ?? 'Unnamed';
                        final imageUrl = attr['image'] as String? ?? '';
                        final description = attr['description'] as String? ?? '';
                        final location = attr['location'] as String? ?? '';
                        final rating = attr['rating'] as String? ?? '4.5';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _AttractionCard(
                            name: name,
                            imageUrl: imageUrl,
                            description: description,
                            location: location,
                            rating: rating,
                            onTap: () => Get.to(
                              () => const AttractionDetailsPage(),
                              arguments: attr,
                              transition: Transition.rightToLeft,
                            ),
                          ),
                        );
                      },
                      childCount: attractions.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
    );
  }
}

// Horizontal Attraction Card
class _AttractionCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String description;
  final String location;
  final String rating;
  final VoidCallback onTap;

  const _AttractionCard({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = location.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Image (Square, rounded left) ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: SizedBox(
                width: 110,
                height: 130,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 110,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            // ── Right: Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Rating stars
                    Row(
                      children: [
                        
                        if (hasLocation)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    

                    // ── View Details Button ──
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
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
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 110,
      height: 130,
      color: AppColor.primary.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.place_outlined,
          size: 32,
          color: AppColor.primary.withOpacity(0.35),
        ),
      ),
    );
  }
}
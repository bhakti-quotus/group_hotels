// restaurant_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'restaurant_detail_page.dart';

class RestaurantListPage extends StatelessWidget {
  final List<dynamic> restaurants;
  final String? title;

  const RestaurantListPage({super.key, required this.restaurants, this.title});

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
                  "Restaurant",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title ?? 'Royal Continental Hotel',
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
      body: restaurants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 56,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No restaurants available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savor a culinary journey at our diverse restaurants.',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final restaurant = restaurants[index] as Map<String, dynamic>;
                        final name = restaurant['name'] as String? ?? 'Unnamed Restaurant';
                        final imageUrl = restaurant['image'] as String? ?? '';
                        final location = restaurant['location'] as String? ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: RestaurantCard(
                            name: name,
                            imageUrl: imageUrl,
                            location: location,
                            onTap: () => Get.to(
                              () => RestaurantDetailPage(restaurant: restaurant),
                              transition: Transition.rightToLeft,
                            ),
                          ),
                        );
                      },
                      childCount: restaurants.length,
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 20),
                ),
              ],
            ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String location;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            SizedBox(
              width: double.infinity,
              height: 200,
              child: imageUrl.isNotEmpty
                  ? Stack(
                      children: [
                        Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: AppColor.primary.withOpacity(0.08),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // Subtle gradient overlay at bottom of image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.18),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 200,
                      color: AppColor.primary.withOpacity(0.08),
                      child: Center(
                        child: Icon(
                          Icons.restaurant_menu_outlined,
                          size: 48,
                          color: AppColor.primary.withOpacity(0.4),
                        ),
                      ),
                    ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),

                  // Location — only if available
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColor.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Divider line with dot — the -·- motif
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 1.5,
                        color: AppColor.primary.withOpacity(0.35),
                      ),
                      const Spacer(),

                      // View Details button
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(50),
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
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 11,
                              ),
                            ],
                          ),
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
}
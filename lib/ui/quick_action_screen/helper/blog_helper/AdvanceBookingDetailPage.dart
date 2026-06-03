// lib/ui/offers_page/black_friday_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdvanceBookingDetailPage extends StatelessWidget {
  const AdvanceBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with back button
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0A2E5C),
              foregroundColor: Colors.white,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.asset(
                      'assets/images/blog8.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0A2E5C),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Title at bottom of app bar
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2E5C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ADVANCE BOOKING OFFER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Family-friendly stays across our destinations',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Main Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Family-friendly stays across our destinations',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Georgia',
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 6,
                          ),

                          child: const Text(
                            '18th July 2025',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 106, 107, 107),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Text(
                          'Planning a family vacation? Our thoughtfully designed family rooms are ready to welcome you! Stay with us at our spacious layout that has comfortable amenities and wonderful views across all our 3 destinations.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3 Cards as per your image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildOfferCard(
                          title: 'Family Rooms That Fit Everyone Comfortably',
                          subtitle:
                              'Stella Di Mare Dubai Marina Hotel – Dubai, UAE',
                          description:
                              'Our 110 sqm Family room is thoughtfully designed to bring ease and comfort to your family getaway. The large windows invite in natural light whilst revealing the lovely city views, creating a bright, welcoming atmosphere for up to 3 adults and 2 children. Choose between a king or twin bed setup and enjoy complimentary coffee and tea to sip and relax.',
                          imagePath: 'assets/images/blog5.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title: 'Where Comfort Meets Family Time',
                          subtitle:
                              'Stella Di Mare Grand Hotel – Ain Sokhna, Egypt',
                          description:
                              'Surrounded by greenery and calmness, our Family room offers 77 sqm of inviting space with its sleek, modern design and a private terrace overlooking the lush and stunning views of the gardens. Our rooms are an ideal setting for your family vacation, for up to 2 adults and 2 children.',
                          imagePath: 'assets/images/blog6.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title: 'Family Stays Made Easy and Enjoyable',
                          subtitle:
                              'Stella Di Mare Beach Hotel & Spa – Sharm El Sheikh, Egypt',
                          description:
                              'Enjoy a peaceful family retreat in our spacious 44 sqm Family Rooms. Wake up to a calming garden view and enjoy the spacious room for 2 adults and 2 children. The rooms are designed for relaxation, featuring a king-sized bed and a cosy living area with a sofa bed, located outside the hotel’s main building near the beach.',
                          imagePath: 'assets/images/blog7.png',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card widget matching the image design
  Widget _buildOfferCard({
    required String title,
    required String subtitle,
    required String description,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEEE8DE),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Color(0xFFBBB0A0),
                  ),
                ),
              ),
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0A2E5C),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

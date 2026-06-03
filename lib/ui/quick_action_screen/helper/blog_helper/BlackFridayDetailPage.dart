// lib/ui/offers_page/black_friday_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlackFridayDetailPage extends StatelessWidget {
  const BlackFridayDetailPage({super.key});

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
                      'assets/images/blog1.jpeg',
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
                              'BLACK FRIDAY SALE',
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
                            'Black Friday Sale',
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
                          'Discover Exceptional Escapes with Stella Di Mare Hotels',
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
                            '26th September 2025',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 106, 107, 107),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Welcome Serenity and Captivating Nature with Open Arms',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 69, 68, 68),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'With a spectacular view of ocean\'s celestial hues, private beaches and an incredible variety of cuisines, Stella Di Mare Hotels and Resorts are your ideal escape, with destinations that vary from Sharm El Sheikh and Ain Sokhna to the city of future, "Dubai".',
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
                          title:
                              'Fusion of Tradition, Innovation and an International Atmosphere',
                          subtitle:
                              'Stella Di Mare Dubai Marina Hotel – Dubai, UAE',
                          description:
                              'The Stella Di Mare Dubai Hotel, where innovation and tradition collide, is the ideal starting point for both business and exploration. In the centre of Dubai Marina, this five-star hotel features a sophisticated yet welcoming Art Deco design, offering a sophisticated yet welcoming stay in one of the world’s most dynamic cities. Dubai provides the backdrop for life-changing experiences with its tall skyscrapers, immaculate beaches, and never-ending entertainment options. Every visitor is made to feel completely at home at Stella Di Mare Dubai Marina thanks to our dedication to going above and beyond. Families and all types of travelers will love the hotel’s two swimming pools, which include a special children’s pool, and access to the neighboring JBR public beach. Our rooms are tastefully decorated for both comfort and elegance.',
                          imagePath: 'assets/images/blog2.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title: 'Let Ain Sokhna Magic Renew Your Spirit',
                          subtitle:
                              'Stella Di Mare Grand Hotel – Ain Sokhna, Egypt',
                          description:
                              'Stella Di Mare Grand Hotel Ain Sokhna Hotel has the ideal location for a relaxing, rejuvenating and taking in the splendor and beauty of the Red Sea because of its gorgeous waters and soft waves that creates calming atmosphere. Our coastal retreat that is known for its pleasant year-round weather, provide the perfect backdrop for vacations in any season. Stella Di Mare Grand Hotel is encircled by the stunning natural scenery and popular Red Sea attractions. Our roomy accommodations and 24-hour room service (Dial 4200) guarantee that comfort is always within reach, whether you are here for a short vacation or a longer one. Host productive and memorable events in a setting that blends functionality with charm. One of our 6 versatile meeting rooms, such as Cleopatra, spans 624 sqm with the largest seating position called Theatre that can hold up to 500, whilst the other meeting room that is 171 sqm, called Marcus Antonius, has boardroom seating positions that hold up to 30 or banquet seating that holds up to 100.',
                          imagePath: 'assets/images/blog3.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title:
                              'Discover a slice of Red Sea Egypt paradise you didn’t realize existed',
                          subtitle:
                              'Stella Di Mare Beach Hotel & Spa – Sharm El Sheikh, Egypt',
                          description:
                              'Located along the shores of Naama Bay, Stella Di Mare Beach Hotel & Spa in Sharm El Sheikh offers elegant Five Star hospitality along with exceptional diving and exquisite dining tailored for family vacations and romantic escapades. With everything you need for an unforgettable holiday, family trip, romantic rendezvous, or even a productive business getaway, it is indeed a remarkable destination.While Stella Di Mare Beach Hotel & Spa is well known for its warm hospitality, guests can enjoy a variety of activities available, ranging from energetic programmes to more leisurely quests. Nestled by our private beach, the hotel offers snorkeling and diving experiences, which also includes certified courses, revealing the wonderful marine life of the Red Sea. Guests can indulge in diverse dinning options, from privately curated BBQ made for you to serving flavourful Asian cuisines such as delicious sushi. We also provide complimentary shuttle service, making it easy and effortless to discover Sharm El Sheikh’s town centre.',
                          imagePath: 'assets/images/blog4.png',
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

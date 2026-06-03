// lib/ui/offers_page/black_friday_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MinimumStayDetailPage extends StatelessWidget {
  const MinimumStayDetailPage({super.key});

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
                      'assets/images/blog9.jpeg',
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
                              'MINIMUM STAY SPECIAL',
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
                            'Stella Di Mare Dubai Marina Hotel Journey to Sustainability',
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
                          'Stella Di Mare Dubai Marina Hotel Journey to Sustainability',
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
                            '17th November 2024',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 106, 107, 107),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'From providing electric vehicle (EV) chargers to growing our own fresh vegetables in our Stella Garden, we are leading the way as the only hotel in the area with a truly comprehensive approach to sustainability.',
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
                          title: 'Charging towards a greener future:',
                          description:
                              'We are proud to be the only hotel in Dubai Marina area that offer our guests EV charging stations. By providing essential service for our guests, we are directly helping to reduce greenhouse gas emissions to make it easier for guests to choose an environmentally friendly means of transportation than a traditional gasoline-powered car.',
                          imagePath: 'assets/images/sustain7.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title: 'Freshness from our garden:',
                          description:
                              'With thoughtful and local solution, we have set up our own vegetable garden, where we grow fresh produce for our restaurants. Our Chefs and Gardeners collaborate and then the chefs incorporate these fresh produce into deliciously made dishes that are flavourful.',
                          imagePath: 'assets/images/blog10.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title: 'Dubai Sustainable Tourism Stamp 2024',
                          description:
                              'Located along the shores of Naama Bay, Stella Di Mare Beach Hotel & Spa in Sharm El Sheikh offers elegant Five Star hospitality along with exceptional diving and exquisite dining tailored for family vacations and romantic escapades. With everything you need for an unforgettable holiday, family trip, romantic rendezvous, or even a productive business getaway, it is indeed a remarkable destination.While Stella Di Mare Beach Hotel & Spa is well known for its warm hospitality, guests can enjoy a variety of activities available, ranging from energetic programmes to more leisurely quests. Nestled by our private beach, the hotel offers snorkeling and diving experiences, which also includes certified courses, revealing the wonderful marine life of the Red Sea. Guests can indulge in diverse dinning options, from privately curated BBQ made for you to serving flavourful Asian cuisines such as delicious sushi. We also provide complimentary shuttle service, making it easy and effortless to discover Sharm El Sheikh’s town centre.',
                          imagePath: 'assets/images/blog11.png',
                        ),

                        ///---------------
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title:
                              'Honored for our Leftover Food Recycling Campaign:',
                          description:
                              'Our commitment to sustainability has earned us a Certification of Appreciation from the UAE Food Bank as a result of our ‘Leftover Food Recycling’ campaign. By participating, we are not only motivated to continue finding ways to minimize negative environmental impact, but also putting efforts in contributing to a healthier planet by reducing waste.',
                          imagePath: 'assets/images/blog12.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title:
                              'Prestigious Integrated Management system certification ',
                          description:
                              'What is a further proof of our dedication, is our achievement of receiving certification ISO 9001, ISO 14001, and ISO 45001. Which indicates our commitment to quality and the environment. Also earning the esteemed EcoCheck GSTC Certification by Intertek Cristal. These internally recognized standards assure environmental responsibility, quality management and workplace safety, that leads to assuring our guests that their comfort and well-being are our priority whilst being environmentally conscious.',
                          imagePath: 'assets/images/blog13.png',
                        ),
                        const SizedBox(height: 20),
                        _buildOfferCard(
                          title: 'But our dedication doesn’t stop:=',
                          description:
                              'We proudly team up with our local authorities on sustainability and environmentally friendly initiatives in the hopes of a positive impact in Dubai, UAE. Such examples include how we did a ‘Can Collection Drive’ campaign and we dropped 44kgs of cans for recycling and dropping off 459kg of plastic to contribute to campaigns of Emirates Environmental Group. We were also involved in the ‘UAE Clean Up’ Campaigns that is committed to COP28 UAE.\nAt Stella Di Mare Dubai Marina Hotel, we are leading the charge in being eco-friendly as we believe that every small or big decision, makes a meaningful difference.As a team we are continuously working on finding ways of protecting our natural surroundings while developing a greener, healthier community for all.',
                          imagePath: 'assets/images/blog14.png',
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
    //required String subtitle,
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
                // const SizedBox(height: 4),
                // Text(
                //   subtitle,
                //   style: const TextStyle(
                //     fontSize: 13,
                //     fontWeight: FontWeight.w500,
                //     color: Color(0xFF0A2E5C),
                //     height: 1.3,
                //   ),
                // ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const Color _kPrimary = Color(0xFFE8334A);
const Color _kNavy = Color(0xFF1A2E6C);
const Color _kBg = Color(0xFFF4F6FA);

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════════
class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqCategory {
  final String title;
  final List<_FaqItem> items;
  const _FaqCategory({required this.title, required this.items});
}

const _faqData = [
  _FaqCategory(
    title: 'Eating & Drinking Questions',
    items: [
      _FaqItem(
        question: 'What can I expect on the breakfast and lunch menus?',
        answer:
            'Our breakfast buffet offers a wide variety of fresh fruits, hot dishes, cereals, pastries, and a made-to-order egg station. Lunch features a rotating selection of salads, grilled proteins, local specialties, and a light bites counter. Both meals are included in your all-inclusive package and are served at designated dining venues across the resort.',
      ),
      _FaqItem(
        question:
            'Is all the food focused around a healthier lifestyle is there a "non healthy" choice available?',
        answer:
            'While BodyHoliday is known for its wellness focus, we firmly believe that indulgence is part of a balanced life. Our menus always include comfort food options alongside lighter, nutrition-focused dishes. You will find burgers, pasta, desserts, and more available at every meal service. We want every guest to feel at home and fully satisfied.',
      ),
      _FaqItem(
        question: 'What is the dress code for the restaurants?',
        answer:
            'Throughout your stay here with us we ask that you look presentable within the meal areas.\n\nBreakfast and lunch and also dinner in the clubhouse are all casual affairs, but we do ask that men wear shirts and women a sarong or wrap over their bathing suits.\n\nFor dinner, the Cariblue restaurant and Cariblue Windows dress code is elegantly casual (i.e. no shorts, tee-shirts, slippers etc.).\n\nAs for the dress code at TAO – your holiday finest!',
      ),
      _FaqItem(
        question: 'Are there options for guests with food allergies?',
        answer:
            'Absolutely. Our culinary team takes dietary requirements very seriously. Please inform us of any allergies or intolerances at check-in, or via your concierge, and our chefs will accommodate you at every meal. We cater for nut allergies, gluten intolerance, dairy-free, vegan, and many other requirements.',
      ),
      _FaqItem(
        question: 'Is alcohol included in the all-inclusive package?',
        answer:
            'Yes, a wide selection of alcoholic and non-alcoholic beverages is included in your all-inclusive package. This covers beers, wines, spirits, cocktails, soft drinks, juices, and water throughout the day and evening at all our bars and restaurants.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Questions about Activities',
    items: [
      _FaqItem(
        question: 'What activities/classes are available?',
        answer:
            'We offer an extensive daily programme of over 35 activities and classes. These include yoga, Pilates, TRX, aqua aerobics, tennis, beach volleyball, snorkelling, kayaking, sailing, windsurfing, and many more. Our wellness schedule also features meditation, stretching, and mindfulness sessions. A full timetable is available at the Sports & Activities desk on arrival.',
      ),
      _FaqItem(
        question: 'How safe it is to swim in the sea?',
        answer:
            'Guest safety is our absolute priority. Our beach is supervised by trained lifeguards during all active hours. We use a flag system to indicate sea conditions — green for safe, yellow for caution, and red for no swimming. The sea conditions are assessed every morning, and our team is always on hand to advise guests accordingly.',
      ),
      _FaqItem(
        question: 'Do I need to book activities in advance?',
        answer:
            'Some activities, particularly water sports, tennis coaching, and spa treatments, are in high demand and we recommend booking in advance through the activities desk or via our app. Many group fitness classes operate on a drop-in basis and no reservation is required.',
      ),
      _FaqItem(
        question: 'Are activities included in the room rate?',
        answer:
            'The majority of our daily activities and group classes are fully included in your all-inclusive rate. Certain specialist sessions such as scuba diving, private tennis coaching, and some water sports excursions carry an additional charge. Our team will always advise you of any costs before you book.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Spa & Wellness',
    items: [
      _FaqItem(
        question: 'What spa treatments are available?',
        answer:
            'Our award-winning spa offers over 100 treatments drawn from healing traditions around the world. These include Ayurvedic therapies, deep tissue massage, hot stone therapy, facials, body wraps, and reflexology. Each guest receives one complimentary treatment per day as part of the all-inclusive package.',
      ),
      _FaqItem(
        question: 'Is the daily spa treatment included for all guests?',
        answer:
            'Yes, one complimentary spa treatment per person per day is included for all guests. This can be selected from a curated menu of signature treatments. Additional treatments can be booked at a preferential in-house rate. We recommend scheduling your treatments early in your stay to secure your preferred time slots.',
      ),
    ],
  ),
  _FaqCategory(
    title: 'Resort & Accommodation',
    items: [
      _FaqItem(
        question: 'What time is check-in and check-out?',
        answer:
            'Standard check-in is from 3:00 PM and check-out is by 12:00 noon. Early check-in and late check-out may be available on request, subject to room availability. Luggage storage is available complimentarily should you arrive before your room is ready.',
      ),
      _FaqItem(
        question: 'Is Wi-Fi available throughout the resort?',
        answer:
            'Complimentary high-speed Wi-Fi is available throughout the resort including all guest rooms, restaurants, public areas, and the beach. Simply connect to the BodyHoliday network and follow the on-screen instructions. Our team at reception can assist you if you experience any connectivity issues.',
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// FAQ LIST PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kNavy),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'FAQ',
            style: TextStyle(
              color: _kNavy,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_faqData.length, (catIndex) {
                  final cat = _faqData[catIndex];
                  return _CategorySection(
                    category: cat,
                    isLast: catIndex == _faqData.length - 1,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category section ─────────────────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final _FaqCategory category;
  final bool isLast;
  const _CategorySection(
      {required this.category, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            category.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _kNavy,
            ),
          ),
        ),

        // FAQ rows
        ...List.generate(category.items.length, (i) {
          final item = category.items[i];
          final isLastItem = i == category.items.length - 1;
          return _FaqRow(
            item: item,
            showBottomDivider: !isLastItem || !isLast,
            isLastInCard: isLast && isLastItem,
          );
        }),

        // Divider between categories (except last)
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}

// ─── Single FAQ row ───────────────────────────────────────────────────────────
class _FaqRow extends StatelessWidget {
  final _FaqItem item;
  final bool showBottomDivider;
  final bool isLastInCard;
  const _FaqRow(
      {required this.item,
      required this.showBottomDivider,
      required this.isLastInCard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => Get.to(
            () => FaqDetailPage(item: item),
            transition: Transition.rightToLeft,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.question,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444444),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                    size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (showBottomDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FAQ DETAIL PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class FaqDetailPage extends StatelessWidget {
  final _FaqItem item;
  const FaqDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kNavy),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'FAQ',
            style: TextStyle(
              color: _kNavy,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              // Split answer by \n\n into paragraphs
              ...item.answer.split('\n\n').map(
                    (para) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        para,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
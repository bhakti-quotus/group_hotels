// lib/ui/faq_page/faq_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: _FaqHeaderDelegate(
                expandedHeight: 180,
                collapsedHeight: 76,
                builder: (t) => _buildHeader(context, t),
              ),
            ),
          ];
        },
        body: Builder(
          builder: (context) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _faqItems.length,
                        itemBuilder: (context, index) {
                          final item = _faqItems[index];
                          final isLast = index == _faqItems.length - 1;
                          return _FaqItem(faq: item, showDivider: !isLast);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── HEADER WITH COLLAPSE ANIMATIONS ────────────────────────────────────────

  Widget _buildHeader(BuildContext context, double t) {
    // t = 0.0 (expanded) → 1.0 (collapsed)

    // Padding animations
    final double topPadding = lerpDouble(30, 12, t)!;
    final double bottomPadding = lerpDouble(1, 20, t)!;

    // Brand row animations
    final double brandRowOpacity = lerpDouble(1.0, 0.0, t)!;
    final double brandRowHeight = lerpDouble(30, 0, t)!;
    final double brandTextSize = lerpDouble(18, 0, t)!;
    final double brandIconSize = lerpDouble(16, 0, t)!;
    final double brandContainerSize = lerpDouble(28, 0, t)!;

    // Description animation
    final double descriptionOpacity = lerpDouble(1.0, 0.0, t)!;
    final double descriptionHeight = lerpDouble(60.0, 0.0, t)!;

    // Divider animation
    final double dividerOpacity = lerpDouble(1.0, 0.0, t)!;

    // Back button animations
    final double backButtonTopMargin = lerpDouble(0, 20, t)!;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, bottomPadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2E5C), Color(0xFF0D5399), Color(0xFF1A6ABF)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative background circles - fade out on scroll
          Positioned(
            top: -40,
            right: -40,
            child: Opacity(
              opacity: lerpDouble(1.0, 0.0, t)!,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0DFFFFFF),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Opacity(
              opacity: lerpDouble(1.0, 0.0, t)!,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0AFFFFFF),
                ),
              ),
            ),
          ),

          // Main header content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand badge row - animates out
                        SizedBox(
                          height: brandRowHeight,
                          child: Opacity(
                            opacity: brandRowOpacity.clamp(0.0, 1.0),
                            child: Row(
                              children: [
                                Container(
                                  width: brandContainerSize,
                                  height: brandContainerSize,
                                  decoration: BoxDecoration(
                                    color: const Color(0x26FFD700),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: const Color(0x4DFFD700),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    color: const Color(0xFFAD9064),
                                    size: brandIconSize,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'FAQs',
                                  style: TextStyle(
                                    fontSize: brandTextSize,
                                    color: const Color(0xFFAD9064),
                                    letterSpacing: 2.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Description text - animates out
                        if (descriptionOpacity > 0)
                          SizedBox(
                            height: descriptionHeight,
                            child: Opacity(
                              opacity: descriptionOpacity.clamp(0.0, 1.0),
                              child: Text(
                                'Find answers to commonly asked questions about our hotels, services, policies, and more. Everything you need to know for a seamless luxury experience.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
                                  height: 1.3,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Back button
                  Padding(
                    padding: EdgeInsets.only(top: backButtonTopMargin),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Gold shimmer divider - fades out
              if (dividerOpacity > 0) ...[
                const SizedBox(height: 16),
                Opacity(
                  opacity: dividerOpacity.clamp(0.0, 1.0),
                  child: Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x66FFD700),
                          Color(0x99FFD700),
                          Color(0x66FFD700),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── PINNED HEADER DELEGATE ─────────────────────────────────────────────

class _FaqHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(double t) builder;

  const _FaqHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(_FaqHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return SizedBox(height: expandedHeight, child: builder(t));
  }
}

// ─── FAQ DATA MODEL ──────────────────────────────────────────────────────────

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

// ─── FAQ DATA ────────────────────────────────────────────────────────────────

const List<FaqItem> _faqItems = [
  FaqItem(
    question:
        'What are the policies regarding cancelation or change of reservation dates?',
    answer:
        'Stella Di Mare Hotels originally implemented a flexible cancellation policy and it states that the cancellation policy varies based on a seasonal peak. The appropriate cancellation deadline will be displayed on the confirmation page before you book a reservation.',
  ),
  FaqItem(
    question: 'Are there any airports nearby the hotels?',
    answer:
        'Yes, All Stella Di Mare hotels are close to International Airports.\nSharm El Sheikh Hotel is about 20-minutes car ride to Sharm El Sheikh International Airport.\nAin Soukhna Hotel (Grand Hotel) Only 90 minutes away from Cairo International Airport.\nDubai Marina Hotel is about 35 minutes car ride to Dubai International Airport.',
  ),
  FaqItem(
    question:
        'Are there any practical shops like: supermarkets, pharmacies, etc, close to the hotels?',
    answer:
        'Yes, Stella Di Mare hotels premises have a variety of shops nearby at your convenience.',
  ),
  FaqItem(
    question:
        'Does the hotel provide buses or any transportation to go places from and to the hotel?',
    answer:
        'Yes, at Stella Di Mare, we offer transportation services to get you to and from hotel and other places.',
  ),
  FaqItem(
    question: 'Is there a medical team on the hotel premises?',
    answer:
        'Our hotels teams are ready to assist and ensure the safety and well-being of everyone. They can connect guests with the best locally available resources and local medical advisors, with "Doctor on call" services but some of our hotels have resident doctors.',
  ),
  FaqItem(
    question: 'Are there any hotels that allow pets?',
    answer:
        'Unfortunately, for the time being no pets are allowed at any of our hotels.',
  ),
  FaqItem(
    question: 'What languages do the hotel staff speak?',
    answer:
        'Our beloved staff at the front desk, guest relations and reception are multilingual as they speaking English.',
  ),
  FaqItem(
    question: 'What meals plans are offered at the hotels?',
    answer:
        'Depending on your request as our hotels provide from bed only to all-inclusive.',
  ),
  FaqItem(
    question: 'Which credit cards are accepted?',
    answer: 'Accepted credit cards are: Visa, Mastercard and American Express.',
  ),
];

// ─── FAQ ITEM WIDGET (EXPANDABLE) ───────────────────────────────────────────

class _FaqItem extends StatefulWidget {
  final FaqItem faq;
  final bool showDivider;

  const _FaqItem({required this.faq, required this.showDivider});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Question row (always visible)
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: _isExpanded ? const Color(0xFFF8F6F2) : Colors.transparent,
            ),
            child: Row(
              children: [
                // Expand/collapse icon
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2E5C).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF0A2E5C),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Question text
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: _isExpanded
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: _isExpanded
                          ? const Color(0xFF0A2E5C)
                          : const Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Answer (visible when expanded)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gold decorative line
                Container(
                  width: 3,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFAD9064), Color(0x99FFD700)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14),
                // Answer text
                Expanded(
                  child: Text(
                    widget.faq.answer,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF555555),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),

        // Divider
        if (widget.showDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            height: 1,
            color: const Color(0xFFE8E0D4),
          ),
      ],
    );
  }
}

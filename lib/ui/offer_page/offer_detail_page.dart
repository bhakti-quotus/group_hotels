// offer_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import '../facilities_page/pdf_viewer_page.dart';

class OfferDetailPage extends StatefulWidget {
  final Map<String, dynamic> offer;

  const OfferDetailPage({super.key, required this.offer});

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
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

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      color: AppColor.primary.withOpacity(0.10),
      child: Center(
        child: loading
            ? CircularProgressIndicator(color: AppColor.primary)
            : Icon(
                Icons.local_offer_outlined,
                size: 64,
                color: AppColor.primary.withOpacity(0.4),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final name = offer['name'] as String? ?? 'Offer Details';
    final imageUrl = offer['image'] as String? ?? '';
    final description = offer['details']?['fullDescription'] as String? ?? '';
    final discount = offer['discount'] as String? ?? '';
    final validTill = offer['valid_till'] as String? ?? '';
    final location = offer['location'] as String? ?? '';
    final offerDetails = (offer['offerdetails'] as List<dynamic>?) ?? [];
    final detailsMap = offer['details'] as Map<String, dynamic>?;
    final menuItems = (offer['menu'] as List<dynamic>?) ?? [];
    final termsConditions = offer['terms_conditions'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero App Bar (Same as Restaurant) ──
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

                  // Discount & Valid Till Badges (Top Right)
                  Positioned(
                    top: 60,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (discount.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColor.secondary, AppColor.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (validTill.isNotEmpty) ...[
                          if (discount.isNotEmpty) const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Valid till $validTill',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Name + accent bar (Same as Restaurant)
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
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body (Similar to Restaurant but with offer content) ──
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
                    'Exclusive Offer',
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

                  // Offer Details Section
                  if (offerDetails.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle('What\'s Included'),
                    const SizedBox(height: 16),
                    ...offerDetails.asMap().entries.map((entry) {
                      final index = entry.key;
                      final detail = entry.value as Map<String, dynamic>;
                      final detailName = detail['name'] as String? ?? '';
                      final detailDesc = detail['desc'] as String? ?? '';
                      return _buildDetailItem(
                        title: detailName,
                        description: detailDesc,
                        isLast: index == offerDetails.length - 1,
                      );
                    }).toList(),
                  ],

                  // Menu Section
                  if (menuItems.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle('Menu & Downloads'),
                    const SizedBox(height: 16),
                    ...menuItems.map((menuItem) {
                      final menuMap = menuItem as Map<String, dynamic>;
                      final menuName = menuMap['name'] as String? ?? 'View PDF';
                      final menuPdf = menuMap['pdf'] as String? ?? menuMap['url'] as String? ?? '';
                      return _buildMenuButton(
                        title: menuName,
                        pdfUrl: menuPdf,
                      );
                    }).toList(),
                  ],

                  // Terms & Conditions Section
                  if (termsConditions.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle('Terms & Conditions'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        termsConditions,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.6,
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String description,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                if (description.isNotEmpty) ...[
                  if (title.isNotEmpty) const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({required String title, required String pdfUrl}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: pdfUrl.isNotEmpty
            ? () => Get.to(() => PdfViewerPage(url: pdfUrl))
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColor.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
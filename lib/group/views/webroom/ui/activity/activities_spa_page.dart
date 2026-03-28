// activities_spa_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:group/group/views/webroom/controller/activities_spa_controller.dart';
import 'package:group/group/views/webroom/common/activities_spa_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — call Get.to(() => const ActivitiesSpaPage())
// ─────────────────────────────────────────────────────────────────────────────

class ActivitiesSpaPage extends StatelessWidget {
  const ActivitiesSpaPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ActivitiesSpaController>()) {
      Get.put(ActivitiesSpaController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        leading: BackButton(color: AppColor.primary),
        title: Text(
          'Activities & Spa',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: const _ActivitiesSpaBody(),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _ActivitiesSpaBody extends StatelessWidget {
  const _ActivitiesSpaBody();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ActivitiesSpaController>();

    return Column(
      children: [
        _SearchBar(ctrl: ctrl),
        _CategoryChips(ctrl: ctrl),
        Expanded(child: _ActivitiesList(ctrl: ctrl)),
      ],
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ActivitiesSpaController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => ctrl.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search an activity or service',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter icon button
          Obx(
            () => GestureDetector(
              onTap: () {
                ctrl.openFilterSheet();
                _showFilterSheet(context, ctrl);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ctrl.hasActiveFilter
                      ? AppColor.primary.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.tune,
                        color: ctrl.hasActiveFilter
                            ? AppColor.primary
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    if (ctrl.hasActiveFilter)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final ActivitiesSpaController ctrl;
  const _CategoryChips({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chipCategories = ctrl.chipCategories;
      final activeChip = ctrl.activeChip.value;
      return SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chipCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = chipCategories[i];
              final selected = activeChip == cat;
              return GestureDetector(
                onTap: () => ctrl.selectChipCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColor.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

// ─── Activities list ──────────────────────────────────────────────────────────

class _ActivitiesList extends StatelessWidget {
  final ActivitiesSpaController ctrl;
  const _ActivitiesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.filteredItems;
      if (items.isEmpty) {
        return const Center(
          child: Text(
            'No activities found',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        itemBuilder: (_, i) => _ActivityCard(item: items[i]),
      );
    });
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ActivityCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const _ActivityCard({required this.item});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  List<String> get _images {
    final imgs = widget.item['images'] as List<dynamic>?;
    if (imgs != null && imgs.isNotEmpty) return imgs.cast<String>();
    final single = widget.item['image'] as String?;
    return single != null ? [single] : [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasLabel = item['priceLabel'] != null;
    final images = _images;

    return GestureDetector(
      onTap: () => _showDetailSheet(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 180,
                    child: images.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (_, i) => Image.network(
                              images[i],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                // Price label badge
                if (hasLabel)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['priceLabel'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Dot indicators (only shown if > 1 image)
                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (i) => Container(
                          width: i == _currentPage ? 8 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Info row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            item['subtitle'] as String,
                            if (item['price'] != null) item['price'] as String,
                          ].join(' · '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['duration'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // + button
                  GestureDetector(
                    onTap: () => _showDetailSheet(context, item),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────

void _showDetailSheet(BuildContext context, Map<String, dynamic> item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DetailSheet(item: item),
  );
}

class _DetailSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  const _DetailSheet({required this.item});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  late final PageController _pageController;
  int _currentPage = 0;

  List<String> get _images {
    final imgs = widget.item['images'] as List<dynamic>?;
    if (imgs != null && imgs.isNotEmpty) return imgs.cast<String>();
    final single = widget.item['image'] as String?;
    return single != null ? [single] : [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasLabel = item['priceLabel'] != null;
    final benefits = item['benefits'] as List<String>;
    final screenH = MediaQuery.of(context).size.height;
    final images = _images;

    return Container(
      height: screenH * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Image Slider Header ───────────────────────────────────────────
          Stack(
            children: [
              // PageView slider
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 220,
                  child: images.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (_, i) => Image.network(
                            images[i],
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 220,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(height: 220, color: Colors.grey[200]),
                ),
              ),

              // Price label badge
              if (hasLabel)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['priceLabel'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Close button
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ),

              // Image counter badge — only shown when > 1 image
              if (images.length > 1)
                Positioned(
                  top: 54,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1} / ${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Dot indicator
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      width: isActive ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),

              // Left arrow
              if (images.length > 1 && _currentPage > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              // Right arrow
              if (images.length > 1 && _currentPage < images.length - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Add to schedule button ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['title']} added to your schedule!'),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'ADD TO MY SCHEDULE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item['subtitle']}  ·  ${item['duration']}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),

                  _SectionTitle('Details'),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _SectionTitle('Options'),
                  const SizedBox(height: 4),
                  Text(
                    item['options'] as String,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),

                  _SectionTitle('Need to Know'),
                  const SizedBox(height: 4),
                  Text(
                    item['needToKnow'] as String,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),

                  _SectionTitle('Benefits'),
                  const SizedBox(height: 6),
                  ...benefits.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
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
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColor.primary,
      ),
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

void _showFilterSheet(BuildContext context, ActivitiesSpaController ctrl) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FilterSheet(ctrl: ctrl),
  );
}

class _FilterSheet extends StatelessWidget {
  final ActivitiesSpaController ctrl;
  const _FilterSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category label with icon
          Row(
            children: [
              Icon(Icons.category_outlined, size: 18, color: AppColor.primary),
              const SizedBox(width: 8),
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category pills
          Obx(() {
            final filterCategory = ctrl.filterCategory.value;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: activitiesCategories.map((cat) {
                final sel = filterCategory == cat;
                return GestureDetector(
                  onTap: () {
                    if (ctrl.filterCategory.value == cat) {
                      ctrl.filterCategory.value = null;
                      ctrl.filterSubcategory.value = null;
                    } else {
                      ctrl.filterCategory.value = cat;
                      ctrl.filterSubcategory.value = null;
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppColor.primary : Colors.white,
                      border: Border.all(
                        color: sel ? AppColor.primary : Colors.grey[300]!,
                        width: sel ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: AppColor.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Colors.grey[700],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 24),

          // Subcategory label with icon
          Row(
            children: [
              Icon(Icons.list_alt_outlined, size: 18, color: AppColor.primary),
              const SizedBox(width: 8),
              const Text(
                'Subcategory',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subcategory dropdown
          Obx(() {
            final subs = ctrl.filterSubcategories;
            final enabled = subs.isNotEmpty;
            final selectedValue = ctrl.filterSubcategory.value;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: selectedValue != null
                      ? AppColor.primary
                      : Colors.grey[300]!,
                  width: selectedValue != null ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: selectedValue != null
                    ? [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 18,
                        color: enabled ? Colors.grey[500] : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        enabled
                            ? 'Select subcategory'
                            : 'Select a category first',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              enabled ? Colors.grey[600] : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  value: selectedValue,
                  items: enabled
                      ? [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Row(
                              children: [
                                Text('All subcategories'),
                              ],
                            ),
                          ),
                          ...subs.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ]
                      : null,
                  onChanged: enabled
                      ? (v) => ctrl.filterSubcategory.value = v
                      : null,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: selectedValue != null
                        ? AppColor.primary
                        : Colors.grey[500],
                    size: 24,
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selectedValue != null
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: selectedValue != null
                        ? AppColor.primary
                        : Colors.black87,
                  ),
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }),

          const SizedBox(height: 28),

          // Action buttons
          Row(
            children: [
              Obx(
                () => ctrl.hasActiveFilter
                    ? Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          onPressed: () {
                            ctrl.clearFilter();
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.clear,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Clear all',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (ctrl.hasActiveFilter) const SizedBox(width: 12),
              Expanded(
                flex: ctrl.hasActiveFilter ? 1 : 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ctrl.applyFilter();
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'APPLY FILTERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
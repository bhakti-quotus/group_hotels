import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';

class AddonsScreen extends StatefulWidget {
  const AddonsScreen({Key? key}) : super(key: key);

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  final Map<String, int> _quantities = {};

  // ── Parse arguments ───────────────────────────────────────

  late final List<dynamic> _addons;
  late final Function(List<Map<String, dynamic>>) _onAdd;
  late final VoidCallback _onSkip;
  late final Map<String, Map<String, dynamic>> _groupedAddons;
  late final int _nightsCount;
  late final String _currency;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    _addons = args['addons'] as List<dynamic>;
    _onAdd = args['onAdd'] as Function(List<Map<String, dynamic>>);
    _onSkip = args['onSkip'] as VoidCallback;

    _groupedAddons = _buildGroupedAddons(_addons);
    _nightsCount = _groupedAddons.isEmpty
        ? 1
        : (_groupedAddons.values.first['dates'] as List).length;
    _currency = _groupedAddons.isNotEmpty
        ? _groupedAddons.values.first['currencyCode'] as String
        : 'USD';
  }

  Map<String, Map<String, dynamic>> _buildGroupedAddons(List<dynamic> addons) {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (var addon in addons) {
      if (addon == null) continue;
      final addonMap = addon is Map<String, dynamic> ? addon : null;
      if (addonMap == null) continue;
      final addonData = addonMap['addon'] as Map<String, dynamic>?;
      if (addonData == null) continue;
      final addonId = addonData['id'];
      if (addonId == null) continue;

      if (!grouped.containsKey(addonId)) {
        final imgs = addonData['images'] as List? ?? [];
        grouped[addonId] = {
          'id': addonId,
          'availabilityId': addonMap['id'],
          'name': addonData['name'] ?? 'Add-on',
          'description': addonData['description'] ?? '',
          'price': addonMap['price'] ?? 0,
          'currencyCode': addonMap['currencyCode'] ?? 'USD',
          'postingRhythm': addonData['postingRhythm'] ?? 'per_night',
          'image': imgs.isNotEmpty ? imgs[0] : '',
          'category': addonData['category']?['name'] ?? '',
          'variant': addonData['addonVariant']?['name'] ?? '',
          'dates': [addonMap['date']],
          'totalNights': 1,
        };
      } else {
        final existing = grouped[addonId]!;
        final dates = List<String>.from(existing['dates']);
        dates.add(addonMap['date']?.toString() ?? '');
        existing['dates'] = dates;
        existing['totalNights'] = dates.length;
      }
    }
    return grouped;
  }

  // ── Helpers ───────────────────────────────────────────────

  String _rhythmText(String r) {
    switch (r) {
      case 'per_night':
        return 'per night';
      case 'per_person_per_night':
        return 'per person / night';
      case 'per_stay':
        return 'one-time';
      default:
        return 'per stay';
    }
  }

  List<Map<String, dynamic>> _selected() {
    final List<Map<String, dynamic>> s = [];
    _quantities.forEach((id, qty) {
      if (qty > 0 && _groupedAddons[id] != null) {
        final a = Map<String, dynamic>.from(_groupedAddons[id]!);
        a['quantity'] = qty;
        s.add(a);
      }
    });
    return s;
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sel = _selected();
    final totalItems = sel.fold<int>(0, (s, a) => s + (a['quantity'] as int));
    final totalPrice = sel.fold<double>(
      0,
      (s, a) => s + (a['price'] as num) * (a['quantity'] as int),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────
            _buildHeader(),

            // ── Addon list ───────────────────────────────────
            Expanded(
              child: _groupedAddons.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _groupedAddons.length,
                      itemBuilder: (_, i) {
                        final addon = _groupedAddons.values.elementAt(i);
                        final id = addon['id'].toString();
                        final qty = _quantities[id] ?? 0;
                        return _buildAddonCard(addon, id, qty);
                      },
                    ),
            ),

            // ── Bottom CTA ───────────────────────────────────
            _buildBottomBar(sel, totalItems, totalPrice),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  Get.back();
                  _onSkip();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColor.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enhance Your Stay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColor.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '$_nightsCount Night${_nightsCount > 1 ? 's' : ''} · Optional extras',
                      style: TextStyle(fontSize: 13, color: AppColor.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Decorative rule
          Row(
            children: [
              Container(width: 36, height: 2.5, color: AppColor.primary),
              const SizedBox(width: 5),
              Container(width: 12, height: 2.5, color: AppColor.secondary),
              const SizedBox(width: 5),
              Container(
                width: 5,
                height: 2.5,
                color: AppColor.secondary.withOpacity(0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Addon Card ────────────────────────────────────────────

  Widget _buildAddonCard(Map<String, dynamic> addon, String id, int qty) {
    final isSelected = qty > 0;
    final image = addon['image'].toString();
    final description = addon['description'] as String? ?? '';
    final rhythm = _rhythmText(addon['postingRhythm'] as String? ?? '');
    final category = addon['category'] as String? ?? '';
    final variant = addon['variant'] as String? ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColor.primary : Colors.grey[200]!,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColor.primary.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(19),
                  bottomLeft: Radius.circular(19),
                ),
                child: SizedBox(
                  width: 100,
                  height: 120,
                  child: Image.network(
                    image.isNotEmpty
                        ? image
                        : 'https://duve.com/wp-content/uploads/2022/12/Hotel-Amenities-1.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColor.primary.withOpacity(0.08),
                      child: Icon(
                        Icons.spa_outlined,
                        color: AppColor.primary.withOpacity(0.3),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category pill
                      if (category.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColor.secondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Name
                      Text(
                        addon['name'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColor.text,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (variant.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          variant,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.textLight,
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Price + rhythm
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_currency ${addon['price']}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColor.primary,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Text(
                              rhythm,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColor.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Description (if any)
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Divider + stepper row
          Container(
            height: 1,
            color: isSelected
                ? AppColor.primary.withOpacity(0.1)
                : Colors.grey[100],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total for selection
                if (qty > 0)
                  Text(
                    'Subtotal: $_currency ${(addon['price'] as num) * qty}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  )
                else
                  Text(
                    'Add to your stay',
                    style: TextStyle(fontSize: 12, color: AppColor.textLight),
                  ),

                // Quantity stepper
                Row(
                  children: [
                    _stepperBtn(
                      icon: Icons.remove_rounded,
                      enabled: qty > 0,
                      onTap: () => setState(() => _quantities[id] = qty - 1),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      alignment: Alignment.center,
                      child: Text(
                        '$qty',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: qty > 0 ? AppColor.primary : AppColor.text,
                        ),
                      ),
                    ),
                    _stepperBtn(
                      icon: Icons.add_rounded,
                      enabled: true,
                      onTap: () => setState(() => _quantities[id] = qty + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stepper Button ────────────────────────────────────────

  Widget _stepperBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? AppColor.primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColor.primary : Colors.grey[400],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.spa_outlined,
              size: 48,
              color: AppColor.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Add-ons Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No extras available for these dates',
            style: TextStyle(fontSize: 13, color: AppColor.textLight),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────

  Widget _buildBottomBar(
    List<Map<String, dynamic>> sel,
    int totalItems,
    double totalPrice,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary strip
          if (totalItems > 0) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.primary.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 16,
                        color: AppColor.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalItems item${totalItems > 1 ? 's' : ''} added',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.text,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$_currency ${totalPrice.toInt()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          Row(
            children: [
              // Skip button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    _onSkip();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Continue button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    _onAdd(sel);
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.primary, AppColor.primary],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          totalItems == 0
                              ? 'Continue'
                              : 'Continue with $totalItems item${totalItems > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
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

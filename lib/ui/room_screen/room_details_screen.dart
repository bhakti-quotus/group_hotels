import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/auth_controller.dart';
import 'package:group/group/controllers/search_controller.dart' as search_ctrl;
import 'package:group/ui/dialog/dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../booking_page/booking_page_new.dart';

class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({Key? key}) : super(key: key);

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  int _currentImageIndex = 0;
  late List<String> images;
  int? _expandedPolicyIndex;
  final Map<int, GlobalKey> _policyKeys = {};
  OverlayEntry? _overlayEntry;
  final PageController _pageController = PageController();

  // Global discount state - applies to ALL rate plans
  String? _globalGuestEmail;
  bool _globalDiscountApplied = false;
  double _globalDiscountedPrice = 0;
  int _globalDiscountPercentage = 0;
  bool _isLoadingDiscount = false;
  String? _globalCurrency;
  double _globalOriginalPrice = 0;
  String? _discountSourceRatePlan;

  @override
  void initState() {
    super.initState();
    _loadSavedDiscountState();
  }

  Future<void> _loadSavedDiscountState() async {
    // You can implement shared_preferences here if you want discount to persist even after app restart
    // For now, it will only persist during the session
  }

  void _clearAllDiscounts() {
    setState(() {
      _globalGuestEmail = null;
      _globalDiscountApplied = false;
      _globalDiscountedPrice = 0;
      _globalDiscountPercentage = 0;
      _globalCurrency = null;
      _globalOriginalPrice = 0;
      _discountSourceRatePlan = null;
      _isLoadingDiscount = false;
    });
    
    Get.snackbar(
      'Discounts Cleared',
      'All applied discounts have been removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> _shareImage() async {
    if (images.isEmpty) return;

    try {
      showSuccessDialog(context, 'Preparing image...');

      final imageUrl = images[_currentImageIndex];
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'shared_room_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${tempDir.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out this beautiful room!',
          subject: 'Room Image',
        );

        Future.delayed(const Duration(seconds: 30), () {
          if (file.existsSync()) {
            file.deleteSync();
          }
        });
      } else {
        showErrorDialog(context, 'Failed to download image');
      }
    } catch (e) {
      showErrorDialog(context, 'Failed to share image');
    }
  }

  void _showPolicyOverlay(BuildContext context, String description, int index) {
    _removeOverlay();

    final policyKey = _policyKeys[index];
    if (policyKey == null) return;

    final RenderBox? renderBox =
        policyKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => _removeOverlay(),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: position.dy + size.height + 8,
            right: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              shadowColor: Colors.black.withOpacity(0.2),
              child: Container(
                width: MediaQuery.of(context).size.width - 120,
                constraints: const BoxConstraints(maxWidth: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.primary.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.policy_rounded,
                            size: 16,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cancellation Policy',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColor.text,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeOverlay(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.5,
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

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _expandedPolicyIndex = index);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _expandedPolicyIndex = null);
  }

  @override
  void dispose() {
    _removeOverlay();
    _pageController.dispose();
    super.dispose();
  }

  void _showAddonsBottomSheet({
    required BuildContext context,
    required List<dynamic> addons,
    required Function(List<Map<String, dynamic>>) onAdd,
    required VoidCallback onSkip,
  }) {
    final Map<String, Map<String, dynamic>> groupedAddons = {};
    
    if (addons.isEmpty) {
      onSkip();
      return;
    }
    
    // Group addons by ID
    for (var addon in addons) {
      if (addon == null) continue;
      
      final addonMap = addon is Map<String, dynamic> ? addon : null;
      if (addonMap == null) continue;
      
      final addonData = addonMap['addon'] as Map<String, dynamic>?;
      if (addonData == null) continue;
      
      final addonId = addonData['id'];
      if (addonId == null) continue;
      
      if (!groupedAddons.containsKey(addonId)) {
        final images = addonData['images'] as List? ?? [];
        final imageUrl = images.isNotEmpty ? images[0] : '';
        
        groupedAddons[addonId] = {
          'id': addonId,
          'name': addonData['name'] ?? 'Add-on',
          'description': addonData['description'] ?? '',
          'price': addonMap['price'] ?? 0,
          'currencyCode': addonMap['currencyCode'] ?? 'USD',
          'postingRhythm': addonData['postingRhythm'] ?? 'per_night',
          'image': imageUrl,
          'category': addonData['category']?['name'] ?? '',
          'variant': addonData['addonVariant']?['name'] ?? '',
          'dates': [addonMap['date']],
          'totalNights': 1,
        };
      } else {
        final existing = groupedAddons[addonId]!;
        final dates = List<String>.from(existing['dates']);
        dates.add(addonMap['date']?.toString() ?? '');
        
        existing['dates'] = dates;
        existing['totalNights'] = dates.length;
      }
    }

    int getNightsCount() {
      if (groupedAddons.isEmpty) return 1;
      return (groupedAddons.values.first['dates'] as List).length;
    }

    final Map<String, int> addonQuantities = {};
    final nightsCount = getNightsCount();

    String getRhythmText(String rhythm) {
      switch (rhythm) {
        case 'per_night':
          return 'per night';
        case 'per_person_per_night':
          return 'per person/night';
        case 'per_stay':
          return 'one-time';
        default:
          return 'per stay';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          List<Map<String, dynamic>> getSelectedAddons() {
            final List<Map<String, dynamic>> selected = [];
            addonQuantities.forEach((addonId, quantity) {
              if (quantity > 0) {
                final addon = groupedAddons[addonId];
                if (addon != null) {
                  final addonWithQty = Map<String, dynamic>.from(addon);
                  addonWithQty['quantity'] = quantity;
                  selected.add(addonWithQty);
                }
              }
            });
            return selected;
          }

          final selectedAddons = getSelectedAddons();
          final totalItems = selectedAddons.fold<int>(
            0, 
            (sum, addon) => sum + (addon['quantity'] as int)
          );
          final totalPrice = selectedAddons.fold<double>(
            0,
            (sum, addon) => sum + (addon['price'] as num) * (addon['quantity'] as int).toDouble()
          );
          final currency = groupedAddons.isNotEmpty 
              ? groupedAddons.values.first['currencyCode'] as String
              : 'USD';

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enhance Your Stay',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add extras to make your stay special',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Stay duration banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.night_shelter,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$nightsCount Night${nightsCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Priced for entire stay',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Add-ons list
                Expanded(
                  child: groupedAddons.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.card_giftcard,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No add-ons available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Check back later for exciting offers',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: groupedAddons.length,
                          itemBuilder: (context, index) {
                            final addon = groupedAddons.values.elementAt(index);
                            final addonId = addon['id'];
                            final quantity = addonQuantities[addonId] ?? 0;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: quantity > 0 
                                      ? AppColor.primary 
                                      : Colors.grey[200]!,
                                  width: quantity > 0 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image on left
                                  ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(15),
                                    ),
                                    child: Container(
                                      width: 100,
                                      height: 120,
                                      color: Colors.grey[100],
                                      child: addon['image'].toString().isNotEmpty
                                          ? Image.network(
                                              addon['image'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 32,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            )
                                          : Image.network(
                                              "https://duve.com/wp-content/uploads/2022/12/Hotel-Amenities-1.jpg",
                                              fit: BoxFit.cover,
                                            )
                                    ),
                                  ),
                                  
                                  // Content
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  addon['name'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColor.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '$currency ${addon['price']}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          if (addon['variant'].isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              addon['variant'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                          
                                          if (addon['description'].isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              addon['description'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          
                                          const SizedBox(height: 8),
                                          
                                          // Rhythm and quantity row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  getRhythmText(addon['postingRhythm']),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                              
                                              // Quantity selector
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    _buildCompactQuantityButton(
                                                      icon: Icons.remove,
                                                      onTap: quantity > 0 
                                                          ? () => setState(() {
                                                              addonQuantities[addonId] = quantity - 1;
                                                            })
                                                          : null,
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        '$quantity',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    _buildCompactQuantityButton(
                                                      icon: Icons.add,
                                                      onTap: () => setState(() {
                                                        addonQuantities[addonId] = quantity + 1;
                                                      }),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          if (quantity > 0) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColor.primary.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Subtotal:',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Text(
                                                    '$currency ${addon['price'] * quantity}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColor.primary,
                                                    ),
                                                  ),
                                                ],
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
                          },
                        ),
                ),
                
                // Bottom bar with total and actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (totalItems > 0) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total ($totalItems item${totalItems > 1 ? 's' : ''})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$currency ${totalPrice.toInt()}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onSkip();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onAdd(selectedAddons);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  totalItems == 0
                                      ? 'Continue'
                                      : 'Continue with $totalItems item${totalItems > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
          );
        },
      ),
    );
  }

  Widget _buildCompactQuantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.white : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppColor.primary : Colors.grey[400],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        backgroundColor: AppColor.background,
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          title: const Text('Room Details'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            if (_globalDiscountApplied)
              IconButton(
                icon: const Icon(Icons.discount_rounded),
                onPressed: _clearAllDiscounts,
                tooltip: 'Clear Discounts',
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No room data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final room = args['room'] as Map<String, dynamic>?;
    if (room == null) {
      return Scaffold(
        backgroundColor: AppColor.background,
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          title: const Text('Room Details'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            if (_globalDiscountApplied)
              IconButton(
                icon: const Icon(Icons.discount_rounded),
                onPressed: _clearAllDiscounts,
                tooltip: 'Clear Discounts',
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Room information not available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalGuests = args['totalGuests'] as int;
    final propertyCode = args['propertyCode'] as String? ?? '';
    final hotelName = args['hotelName'] as String? ?? '';
    final propertyId = args['propertyId'] as String? ?? '';

    final searchController = Get.find<search_ctrl.AppSearchController>();
    final searchPayload = Map<String, dynamic>.from(
      searchController.searchPayload.value,
    );
    final guests = searchPayload['guests'] as Map<String, dynamic>? ?? {};
    final adults = guests['adults'] as int? ?? 1;
    final children = guests['children'] as int? ?? 0;
    final now = DateTime.now();
    final startDate =
        searchPayload['startDate'] as String? ??
        now.add(const Duration(days: 1)).toIso8601String().split('T')[0];
    final endDate =
        searchPayload['endDate'] as String? ??
        now.add(const Duration(days: 2)).toIso8601String().split('T')[0];

    final roomName = room['room_name'] ?? room['name'] ?? '';
    final roomType = room['room_type'] ?? '';
    final roomSize = room['room_size'] ?? 0;
    final roomUnit = room['room_unit'] ?? '';
    final roomView = room['room_view'] ?? '';
    final maxOccupancy = room['max_occupancy'] ?? room['maxOccupancy'] ?? 0;
    final description = room['description'] ?? '';
    images = (room['images'] as List?)?.cast<String>() ?? [];
    final amenities = room['amenities'] as List? ?? [];
    final roomPrice = room['room_price'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColor.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColor.primary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  _removeOverlay();
                  Get.back();
                },
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _shareImage,
                ),
              ),
              if (_globalDiscountApplied)
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.discount_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: _clearAllDiscounts,
                    tooltip: 'Clear Discounts',
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isNotEmpty)
                    Positioned.fill(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 70,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: images.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        images[index],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported_rounded,
                                                    size: 24,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                      if (_currentImageIndex == index)
                                        Container(
                                          color: Colors.black.withOpacity(
                                            0.2,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roomName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.text,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (hotelName.isNotEmpty)
                                Text(
                                  hotelName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (roomType.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              roomType,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
      
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (roomSize > 0)
                          _buildInfoChip(
                            Icons.square_foot_rounded,
                            '$roomSize ${roomUnit.isNotEmpty ? roomUnit : "sq ft"}',
                          ),
                        if (roomView.isNotEmpty)
                          _buildInfoChip(
                            Icons.landscape_rounded,
                            roomView,
                          ),
                        _buildInfoChip(
                          Icons.people_rounded,
                          'Up to $maxOccupancy guests',
                        ),
                      ],
                    ),
      
                    const SizedBox(height: 24),
      
                    _buildSectionHeader('About This Room'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 24),
      
                    _buildSectionHeader('Amenities'),
                    const SizedBox(height: 16),
                    _buildAmenitiesGrid(amenities),
      
                    const SizedBox(height: 24),
      
                    if (roomPrice.isNotEmpty) ...[
                      _buildSectionHeader('Rate Plans'),
                      const SizedBox(height: 16),
                      ...roomPrice.asMap().entries.map((entry) {
                        final index = entry.key;
                        final ratePlan = entry.value;
                        _policyKeys.putIfAbsent(index, () => GlobalKey());
                        return _buildRatePlanCard(
                          ratePlan,
                          room,
                          index,
                          adults,
                          children,
                          totalGuests,
                          startDate,
                          endDate,
                          propertyCode,
                          hotelName,
                          propertyId,
                        );
                      }).toList(),
                    ],
      
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: roomPrice.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildBookButton(
                onPressed: () {
                  _removeOverlay();
                  Get.to(
                    () => BookingPage(
                      room: room,
                      ratePlan: {},
                      totalGuests: totalGuests,
                      adults: adults,
                      children: children,
                      startDate: startDate,
                      endDate: endDate,
                      propertyId: propertyId,
                      propertyCode: propertyCode,
                      hotelName: hotelName,
                    ),
                  );
                },
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColor.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.text,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 60,
          height: 2,
          color: AppColor.primary,
        ),
        Container(
          width: 40,
          height: 2,
          color: AppColor.secondary,
          margin: const EdgeInsets.only(top: 2),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(List amenities) {
    if (amenities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Text(
            'No amenities listed',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: amenities.map((amenity) {
          final amenityName = amenity is String
              ? amenity
              : (amenity['amenityName'] ?? '');
          return _buildAmenityItem(amenityName);
        }).toList(),
      ),
    );
  }

  Widget _buildAmenityItem(String amenityName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getAmenityIcon(amenityName), size: 14, color: AppColor.primary),
          const SizedBox(width: 6),
          Text(
            amenityName,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatePlanCard(
    Map<String, dynamic> ratePlan,
    Map<String, dynamic> room,
    int index,
    int adults,
    int children,
    int totalGuests,
    String startDate,
    String endDate,
    String propertyCode,
    String hotelName,
    String propertyId,
  ) {
    final ratePlanName = ratePlan['ratePlanName'] ?? 'Standard Rate';
    final totalAmount = ratePlan['totalAmount'] ?? 0;
    final currency = ratePlan['currencyCode'] ?? 'USD';
    final ratePlanCode = ratePlan['ratePlanCode'] ?? '';

    final policy = ratePlan['policy'] as Map<String, dynamic>?;
    final cancellationPolicy = policy?['cancellationPolicy'] as Map<String, dynamic>?;
    final description = cancellationPolicy?['description'] ?? '';

    // Discount logic
    bool discountApplied = _globalDiscountApplied;
    double discountedPrice = _globalDiscountedPrice;
    bool isLoadingDiscount = _isLoadingDiscount;
    int discountPercentage = _globalDiscountPercentage;
    String? guestEmail = _globalGuestEmail;

    double getDiscountedPriceForRatePlan() {
      if (!_globalDiscountApplied) return totalAmount.toDouble();
      final originalPrice = totalAmount.toDouble();
      final discountAmount = originalPrice * (_globalDiscountPercentage / 100);
      return originalPrice - discountAmount;
    }

    void _showDiscountForm() {
      final nameController = TextEditingController();
      final emailController = TextEditingController();
      final mobileController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get Exclusive Discount',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 60,
                        height: 2,
                        color: AppColor.primary,
                      ),
                      Container(
                        width: 40,
                        height: 2,
                        color: AppColor.secondary,
                        margin: const EdgeInsets.only(top: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Sign up now to get an exclusive discount on ALL rate plans!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  _buildFormField(
                    controller: nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFormField(
                    controller: emailController,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!GetUtils.isEmail(value)) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFormField(
                    controller: mobileController,
                    label: 'Mobile Number',
                    hint: 'Enter your mobile number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your mobile number';
                      if (value.length < 10) return 'Please enter a valid mobile number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => _isLoadingDiscount = true);
                              
                              try {
                                final response = await http.post(
                                  Uri.parse('https://bookings.revchilltech.com/api/v1/loyalty/guest/check-discount'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: json.encode({
                                    'email': emailController.text.trim(),
                                    'propertyId': propertyId,
                                  }),
                                ).timeout(const Duration(seconds: 10));

                                Navigator.pop(dialogContext);

                                if (response.statusCode == 200) {
                                  final responseData = json.decode(response.body);
                                  
                                  if (responseData['success'] == true && responseData['data'] != null) {
                                    final data = responseData['data'];
                                    final isLoyaltyMember = data['isLoyaltyMember'] ?? false;
                                    
                                    if (isLoyaltyMember) {
                                      final discount = data['discount']?['value'] ?? 0;
                                      
                                      setState(() {
                                        _globalGuestEmail = emailController.text.trim();
                                        _globalDiscountApplied = true;
                                        _globalDiscountPercentage = discount;
                                        _globalCurrency = currency;
                                        _globalOriginalPrice = totalAmount.toDouble();
                                        
                                        final originalPrice = totalAmount.toDouble();
                                        final discountAmount = originalPrice * (discount / 100);
                                        _globalDiscountedPrice = originalPrice - discountAmount;
                                        
                                        _discountSourceRatePlan = ratePlanCode;
                                        _isLoadingDiscount = false;
                                      });
                                      
                                      if (context.mounted) {
                                        showSuccessDialog(
                                          context,
                                          '🎉 $discount% discount applied to all rate plans!',
                                        );
                                      }
                                    } else {
                                      setState(() => _isLoadingDiscount = false);
                                      if (context.mounted) {
                                        showErrorDialog(
                                          context,
                                          'Sorry, you are not eligible for the discount.',
                                        );
                                      }
                                    }
                                  }
                                }
                              } catch (e) {
                                Navigator.pop(dialogContext);
                                setState(() => _isLoadingDiscount = false);
                                if (context.mounted) {
                                  showErrorDialog(context, 'Network error. Please try again.');
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoadingDiscount
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final ratePlanDiscountedPrice = getDiscountedPriceForRatePlan();
    final savings = totalAmount.toDouble() - ratePlanDiscountedPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: discountApplied && _discountSourceRatePlan == ratePlanCode
              ? AppColor.secondary.withOpacity(0.5)
              : Colors.grey[200]!,
          width: discountApplied && _discountSourceRatePlan == ratePlanCode ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Section - Rate Plan Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ratePlanName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor.text,
                              ),
                            ),
                          ),
                          if (discountApplied && _discountSourceRatePlan == ratePlanCode)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Applied',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Includes taxes & fees',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        // Policy text preserved exactly as original
                        Container(
                          key: _policyKeys[index],
                          child: GestureDetector(
                            onTap: () {
                              if (_expandedPolicyIndex == index) {
                                _removeOverlay();
                              } else {
                                _showPolicyOverlay(context, description, index);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Policy',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _expandedPolicyIndex == index
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppColor.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right Section - Price & Book
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (discountApplied) ...[
                      Row(
                        children: [
                          Text(
                            '$currency ${totalAmount.toInt()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '-$discountPercentage%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$currency ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          discountApplied
                              ? '${ratePlanDiscountedPrice.toInt()}'
                              : '${totalAmount.toInt()}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/night',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    if (discountApplied && savings > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Save $currency ${savings.toInt()}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          _removeOverlay();
                          
                          final currentGuestEmail = _globalGuestEmail;

                          if (AuthController.to.isLoggedIn.value) {
                            // Navigate to booking
                            Get.to(
                              () => BookingPage(
                                room: room,
                                ratePlan: ratePlan,
                                totalGuests: totalGuests,
                                adults: adults,
                                children: children,
                                startDate: startDate,
                                endDate: endDate,
                                propertyId: propertyId,
                                propertyCode: propertyCode,
                                hotelName: hotelName,
                                discountApplied: _globalDiscountApplied,
                                discountedPrice: ratePlanDiscountedPrice.toInt(),
                                guestEmail: currentGuestEmail,
                              ),
                            );
                          } else {
                            showErrorDialog(
                              context,
                              'Please login to book a room',
                              onPressed: () {
                                Navigator.pop(context);
                                Get.toNamed(
                                  '/login',
                                  arguments: {
                                    'nextRoute': '/room-details',
                                    'bookingArguments': {
                                      'room': room,
                                      'ratePlan': ratePlan,
                                      'totalGuests': totalGuests,
                                      'adults': adults,
                                      'children': children,
                                      'startDate': startDate,
                                      'endDate': endDate,
                                      'propertyId': propertyId,
                                      'propertyCode': propertyCode,
                                      'hotelName': hotelName,
                                    },
                                    'fromBooking': true,
                                  },
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Book',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Discount Banner
          if (!discountApplied)
            InkWell(
              onTap: _showDiscountForm,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.secondary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColor.secondary.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Get Discount on All Plans',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColor.text,
                            ),
                          ),
                          Text(
                            'Sign up once - discount applies to every rate plan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColor.secondary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppColor.primary),
        labelStyle: TextStyle(color: AppColor.primary),
        focusColor: AppColor.primary,
        prefixIcon: Icon(icon, color: AppColor.secondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColor.secondary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildBookButton({required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Book Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenityName) {
    final name = amenityName.toLowerCase();
    if (name.contains('wifi') || name.contains('internet')) {
      return Icons.wifi_rounded;
    } else if (name.contains('tv') || name.contains('television')) {
      return Icons.tv_rounded;
    } else if (name.contains('ac') || name.contains('air')) {
      return Icons.ac_unit_rounded;
    } else if (name.contains('parking')) {
      return Icons.local_parking_rounded;
    } else if (name.contains('pool') || name.contains('swimming')) {
      return Icons.pool_rounded;
    } else if (name.contains('gym') || name.contains('fitness')) {
      return Icons.fitness_center_rounded;
    } else if (name.contains('breakfast') || name.contains('food')) {
      return Icons.restaurant_rounded;
    } else if (name.contains('bath') || name.contains('shower')) {
      return Icons.bathtub_rounded;
    } else if (name.contains('kitchen')) {
      return Icons.kitchen_rounded;
    } else if (name.contains('pet')) {
      return Icons.pets_rounded;
    } else if (name.contains('balcony')) {
      return Icons.balcony_rounded;
    } else if (name.contains('safe')) {
      return Icons.lock_rounded;
    } else if (name.contains('coffee') || name.contains('tea')) {
      return Icons.coffee_rounded;
    }
    return Icons.check_circle_rounded;
  }
}
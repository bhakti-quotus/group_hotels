import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/utils/app_routes.dart';

class BookingData {
  final String roomName;
  final int basePrice;
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int adults;
  final int children;
  final int infants;
  final List<int> childAges;
  final List<String> infantAges;

  BookingData({
    required this.roomName,
    required this.basePrice,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.adults,
    required this.children,
    required this.infants,
    required this.childAges,
    required this.infantAges,
  });
}

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Map<String, dynamic> roomData = {};
  DateTime checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime checkOut = DateTime.now().add(const Duration(days: 2));
  bool showGuestSelector = false;

  int rooms = 1;
  int adults = 1;
  int children = 0;
  int infants = 0;

  List<int> childAges = [];
  List<String> infantAges = [];

  int get totalGuests => adults + children + infants;
  int get remainingSlots => (4 * rooms) - totalGuests;
  int get totalNights => checkOut.difference(checkIn).inDays;

  // Price calculation with breakdown
  int get basePrice => roomData.isEmpty ? 0 : (roomData['basePrice'] ?? 0);
  int get roomsPrice => basePrice * totalNights * rooms;
  int get adultsPrice => (adults > 1) ? (adults - 1) * 500 * totalNights : 0;
  int get childrenPrice => children * 300 * totalNights;
  int get subtotal => roomsPrice + adultsPrice + childrenPrice;
  double get gstAmount => subtotal * 0.12;
  double get serviceTax => subtotal * 0.05;
  double get totalPrice => subtotal + gstAmount + serviceTax;

  @override
  void initState() {
    super.initState();
    loadRoomData();
  }

  void loadRoomData() {
    final room = Get.arguments['room'];
    setState(() {
      roomData = room;
    });
  }

  void handleChildrenChange(int newValue) {
    if (totalGuests - children + newValue <= 4 * rooms) {
      setState(() {
        children = newValue;
        if (newValue > childAges.length) {
          childAges.addAll(List.filled(newValue - childAges.length, 5));
        } else {
          childAges = childAges.sublist(0, newValue);
        }
      });
    }
  }

  void handleInfantsChange(int newValue) {
    if (totalGuests - infants + newValue <= 4 * rooms) {
      setState(() {
        infants = newValue;
        if (newValue > infantAges.length) {
          infantAges.addAll(
            List.filled(newValue - infantAges.length, '12 months'),
          );
        } else {
          infantAges = infantAges.sublist(0, newValue);
        }
      });
    }
  }

  void handleAdultsChange(int newValue) {
    if (totalGuests - adults + newValue <= 4 * rooms && newValue >= 1) {
      setState(() {
        adults = newValue;
      });
    }
  }

  Future<void> selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime today = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? checkIn : checkOut,
      firstDate: isCheckIn ? today : checkIn.add(const Duration(days: 1)),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: AppColor.primary)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkIn = picked;
          if (checkOut.isBefore(checkIn) || checkOut == checkIn) {
            checkOut = checkIn.add(const Duration(days: 1));
          }
        } else {
          checkOut = picked;
        }
      });
    }
  }

  void navigateToConfirmation() {
    final bookingData = BookingData(
      roomName: roomData['name'] ?? '',
      basePrice: roomData['basePrice'] ?? 0,
      checkIn: checkIn,
      checkOut: checkOut,
      rooms: rooms,
      adults: adults,
      children: children,
      infants: infants,
      childAges: childAges,
      infantAges: infantAges,
    );

    Get.toNamed(AppRoutes.confirmBooking, arguments: bookingData);
  }

  @override
  Widget build(BuildContext context) {
    if (roomData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Room',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColor.primary, AppColor.primary.withOpacity(0.2)],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  // Room Info Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            (roomData['images'] as List).first,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roomData['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Booking Details Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Check-in and Check-out
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => selectDate(context, true),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Check-In',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColor.primary.withOpacity(
                                            0.6,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${checkIn.day}-${checkIn.month}-${checkIn.year}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: AppColor.primary.withOpacity(
                                              0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: const Color(0xFFE2E8F0),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => selectDate(context, false),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Check-Out',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColor.primary.withOpacity(
                                              0.6,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${checkOut.day}-${checkOut.month}-${checkOut.year}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColor.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: AppColor.primary
                                                  .withOpacity(0.4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Divider(height: 1),
                        ),

                        // Guest Summary
                        InkWell(
                          onTap: () {
                            setState(() {
                              showGuestSelector = !showGuestSelector;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Rooms ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.primary.withOpacity(
                                              0.6,
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '$rooms',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • Adults ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.primary.withOpacity(
                                              0.6,
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '$adults',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primary,
                                          ),
                                        ),
                                        if (children > 0) ...[
                                          TextSpan(
                                            text: ' • Children ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.primary
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          TextSpan(
                                            text: '$children',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ],
                                        if (infants > 0) ...[
                                          TextSpan(
                                            text: ' • Infants ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.primary
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          TextSpan(
                                            text: '$infants',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                Icon(
                                  showGuestSelector
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppColor.primary.withOpacity(0.3),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Guest Selector
                        if (showGuestSelector)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Guest Details',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: remainingSlots >= 0
                                            ? AppColor.secondary.withOpacity(
                                                0.1,
                                              )
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Total: $totalGuests/${4 * rooms}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: remainingSlots >= 0
                                              ? AppColor.secondary
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                _buildCompactCounter(
                                  'Rooms',
                                  rooms,
                                  () => setState(() {
                                    if (rooms > 1) rooms--;
                                  }),
                                  () => setState(() {
                                    if (rooms < 5) rooms++;
                                  }),
                                ),
                                const SizedBox(height: 12),

                                _buildCompactCounter(
                                  'Adults',
                                  adults,
                                  () => handleAdultsChange(adults - 1),
                                  () => handleAdultsChange(adults + 1),
                                ),
                                const SizedBox(height: 12),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCompactCounter(
                                      'Children',
                                      children,
                                      () => handleChildrenChange(
                                        children > 0 ? children - 1 : 0,
                                      ),
                                      () => handleChildrenChange(children + 1),
                                    ),
                                    if (children > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12,
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Child Ages (1-12 yrs)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColor.primary
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...List.generate(
                                              children,
                                              (index) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Child ${index + 1}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor.primary
                                                            .withOpacity(0.4),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    _buildAgeSlider(
                                                      selectedAge:
                                                          childAges[index],
                                                      onSelect: (newAge) {
                                                        setState(() {
                                                          childAges[index] =
                                                              newAge;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCompactCounter(
                                      'Infants',
                                      infants,
                                      () => handleInfantsChange(
                                        infants > 0 ? infants - 1 : 0,
                                      ),
                                      () => handleInfantsChange(infants + 1),
                                    ),
                                    if (infants > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12,
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Infant Ages',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColor.primary
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...List.generate(
                                              infants,
                                              (index) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Infant ${index + 1}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor.primary
                                                            .withOpacity(0.4),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: _buildAgeOption(
                                                            'Under 1 year',
                                                            infantAges[index] ==
                                                                '12 months',
                                                            () => setState(() {
                                                              infantAges[index] =
                                                                  '12 months';
                                                            }),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: _buildAgeOption(
                                                            '1-2 years',
                                                            infantAges[index] ==
                                                                '24 months',
                                                            () => setState(() {
                                                              infantAges[index] =
                                                                  '24 months';
                                                            }),
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
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showGuestSelector = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.secondary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'SAVE',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!showGuestSelector) const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Price Breakdown Card
                  if (!showGuestSelector)
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildPriceRow(
                              'AED $basePrice × $totalNights night${totalNights > 1 ? 's' : ''} × $rooms room${rooms > 1 ? 's' : ''}',
                              'AED $roomsPrice',
                            ),

                            if (adults > 1) ...[
                              const SizedBox(height: 8),
                              _buildPriceRow(
                                'Additional adults (${adults - 1} × AED 500 × $totalNights night${totalNights > 1 ? 's' : ''})',
                                'AED $adultsPrice',
                              ),
                            ],

                            if (children > 0) ...[
                              const SizedBox(height: 8),
                              _buildPriceRow(
                                'Children ($children × AED 300 × $totalNights night${totalNights > 1 ? 's' : ''})',
                                'AED $childrenPrice',
                              ),
                            ],

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),

                            _buildPriceRow(
                              'Subtotal',
                              'AED $subtotal',
                              isSubtotal: true,
                            ),

                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'GST (12%)',
                              'AED ${gstAmount.toStringAsFixed(2)}',
                            ),

                            const SizedBox(height: 8),
                            _buildPriceRow(
                              'Service Tax (5%)',
                              'AED ${serviceTax.toStringAsFixed(2)}',
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, thickness: 2),
                            ),

                            _buildPriceRow(
                              'Total Amount',
                              'AED ${totalPrice.toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(fontSize: 12, color: AppColor.textLight),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'AED ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  Text(
                    'for $totalNights night${totalNights > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColor.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: navigateToConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String amount, {
    bool isSubtotal = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal
                  ? FontWeight.bold
                  : (isSubtotal ? FontWeight.w600 : FontWeight.w500),
              color: isTotal
                  ? AppColor.primary
                  : (isSubtotal ? AppColor.text : AppColor.textLight),
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal
                ? FontWeight.bold
                : (isSubtotal ? FontWeight.w600 : FontWeight.w500),
            color: isTotal ? AppColor.primary : AppColor.text,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCounter(
    String title,
    int value,
    VoidCallback onDecrement,
    VoidCallback onIncrement,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
          Row(
            children: [
              _buildCounterButton(
                Icons.remove,
                onDecrement,
                value > (title == 'Adults' ? 1 : 0),
              ),
              Container(
                width: 36,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
              ),
              _buildCounterButton(Icons.add, onIncrement, remainingSlots > 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap, bool enabled) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? AppColor.primary : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.white : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildAgeOption(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColor.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColor.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeSlider({
    required int selectedAge,
    required Function(int) onSelect,
  }) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, index) {
          int age = index + 1;
          bool isSelected = age == selectedAge;

          return GestureDetector(
            onTap: () => onSelect(age),
            child: Container(
              width: 35,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColor.primary : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                age.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColor.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

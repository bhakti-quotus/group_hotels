import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/api_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_page.dart';
import '../../ui/dialog/dialog.dart';
import 'price_breakdown_widget.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> room;
  final Map<String, dynamic> ratePlan;
  final int totalGuests;
  final int adults;
  final int children;
  final String startDate;
  final String endDate;
  final String propertyId;
  final String propertyCode;
  final String hotelName;
  final List<Map<String, dynamic>>? selectedAddons;
  final bool discountApplied;
  final int discountedPrice;
  final String? guestEmail;

  const BookingPage({
    Key? key,
    required this.room,
    required this.ratePlan,
    required this.totalGuests,
    required this.adults,
    required this.children,
    required this.startDate,
    required this.endDate,
    required this.propertyId,
    required this.propertyCode,
    required this.hotelName,
    this.selectedAddons,
    this.discountApplied = false,
    this.discountedPrice = 0,
    this.guestEmail,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _priceData;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<Map<String, TextEditingController>> _adultControllers = [];

  @override
  void initState() {
    super.initState();
    
    // Pre-fill email if discount was applied
    if (widget.guestEmail != null && widget.guestEmail!.isNotEmpty) {
      _emailController.text = widget.guestEmail!;
    }
    
    for (int i = 0; i < widget.adults; i++) {
      _adultControllers.add({
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'dob': TextEditingController(),
      });
    }
    _getPrice();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    for (var controllers in _adultControllers) {
      controllers['firstName']?.dispose();
      controllers['lastName']?.dispose();
      controllers['dob']?.dispose();
    }
    super.dispose();
  }

  Future<void> _getPrice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {
        "propertyCode": widget.propertyCode,
        "invTypeCode":
            widget.room['room_type'] ?? widget.room['invTypeCode'] ?? '',
        "ratePlanCode": widget.ratePlan['ratePlanCode'] ?? '',
        "startDate": widget.startDate,
        "endDate": widget.endDate,
        "noOfRooms": 1,
        "noOfAdults": widget.adults,
        "noOfChildren": widget.children,
      };

      // Add guestEmail to payload if discount was applied
      if (widget.discountApplied && widget.guestEmail != null) {
        payload['guestEmail'] = widget.guestEmail;
        print('Adding guestEmail to price payload: ${widget.guestEmail}');
      }

      // Include selected addons if they exist
      if (widget.selectedAddons != null && widget.selectedAddons!.isNotEmpty) {
        final addonsPayload = widget.selectedAddons!.map((addon) {
          return {
            'addonId': addon['id'] ?? '',
            'availabilityId': addon['id'] ?? '',
            'code': addon['addonCode'] ?? '',
            'date': widget.startDate,
            'name': addon['addonName'] ?? '',
            'price': addon['price'] ?? 0,
            'quantity': addon['quantity'] ?? 1,
            'type': addon['postingRhythm'] ?? 'per_night',
          };
        }).toList();

        payload['addons'] = addonsPayload;
      }

      print('Price API Payload: $payload');

      final result = await Get.find<ApiController>().getPrice(payload);

      if (result['success'] == true) {
        setState(() {
          _priceData = result['data'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        _showError(
          context,
          result['error'] ?? result['message'] ?? 'Failed to get price',
        );
      }
    } catch (e) {
      _showError(context, 'Error getting price: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(BuildContext context, String message) {
    setState(() {
      _isLoading = false;
    });
    showErrorDialog(context, message);
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime today = DateTime.now();
    final DateTime seventeenyearsago = DateTime(
      today.year - 17,
      today.month,
      today.day,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 17, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: seventeenyearsago,
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
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  int _calculateNights() {
    try {
      final start = DateTime.parse(widget.startDate);
      final end = DateTime.parse(widget.endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.primary,
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => {Get.back(), Get.back()},
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (widget.discountApplied)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '10% OFF Applied',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest Details
                    _buildCompactSection(
                      'Guest Details',
                      Icons.person,
                      Column(
                        children: List.generate(widget.adults, (index) {
                          return Column(
                            children: [
                              if (index > 0) const SizedBox(height: 12),
                              if (widget.adults > 1)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Guest ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactField(
                                      controller:
                                          _adultControllers[index]['firstName']!,
                                      label: 'First Name',
                                      icon: Icons.person_outline,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildCompactField(
                                      controller:
                                          _adultControllers[index]['lastName']!,
                                      label: 'Last Name',
                                      icon: Icons.person_outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(
                                  context,
                                  _adultControllers[index]['dob']!,
                                ),
                                child: IgnorePointer(
                                  child: _buildCompactField(
                                    controller:
                                        _adultControllers[index]['dob']!,
                                    label: 'Date of Birth',
                                    icon: Icons.cake_outlined,
                                    readOnly: true,
                                  ),
                                ),
                              ),
                              if (index < widget.adults - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Contact Information
                    _buildCompactSection(
                      'Contact',
                      Icons.contact_mail,
                      Column(
                        children: [
                          _buildCompactField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: widget.guestEmail != null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email address';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildCompactField(
                            controller: _phoneController,
                            label: 'Phone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Price Summary
                    if (_priceData != null)
                      _buildCompactSection(
                        'Price Summary',
                        Icons.receipt_long,
                        Column(
                          children: [
                            PriceBreakdownWidget(priceData: _priceData!),
                            if (widget.discountApplied)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColor.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColor.secondary),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColor.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Discount Applied!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.secondary,
                                            ),
                                          ),
                                          Text(
                                            'You\'re saving 10% on this booking',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColor.secondary.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : () => Get.toNamed('/rooms'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Proceed to Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSection(String title, IconData icon, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColor.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.text,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  Widget _buildCompactField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(
        color: readOnly ? Colors.grey.shade600 : AppColor.text, 
        fontSize: 15,
        fontWeight: readOnly ? FontWeight.w500 : FontWeight.normal,
      ),
      cursorColor: AppColor.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: readOnly ? Colors.grey.shade600 : AppColor.primary, 
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon, 
          size: 18, 
          color: readOnly ? Colors.grey.shade500 : AppColor.primary,
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        counterText: '',
      ),
      validator: validator,
    );
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;

    // Transform guest details
    List<Map<String, dynamic>> guestDetails = [];
    for (var controllers in _adultControllers) {
      guestDetails.add({
        'type': 'adult',
        'firstName': controllers['firstName']?.text ?? '',
        'lastName': controllers['lastName']?.text ?? '',
        'dateOfBirth': controllers['dob']?.text ?? '',
      });
    }

    // Calculate total amount and nights
    final numberOfNights = _calculateNights();

    // Get the final amount (use discounted price if available)
    final totalAmount = widget.discountApplied 
        ? widget.discountedPrice 
        : (_priceData?['totalAmount'] ?? widget.ratePlan['totalAmount'] ?? 0);

    // Construct finalPrice from API response
    final finalPrice = _priceData != null
        ? {
            'totalAmount': totalAmount,
            'originalTotalAmount': _priceData!['totalAmount'] ?? 0,
            'numberOfNights': _priceData!['numberOfNights'] ?? numberOfNights,
            'baseRatePerNight': _priceData!['baseRatePerNight'] ?? 0,
            'additionalGuestCharges':
                _priceData!['additionalGuestCharges'] ?? 0,
            'availableRooms': _priceData!['availableRooms'] ?? 0,
            'breakdown': {
              'totalBaseAmount':
                  _priceData!['breakdown']?['totalBaseAmount'] ??
                  _priceData!['totalAmount'] ??
                  0,
              'totalAdditionalCharges':
                  _priceData!['breakdown']?['totalAdditionalCharges'] ??
                  _priceData!['additionalGuestCharges'] ??
                  0,
              'totalAmount': totalAmount,
              'numberOfNights':
                  _priceData!['breakdown']?['numberOfNights'] ??
                  _priceData!['numberOfNights'] ??
                  numberOfNights,
              'averagePerNight':
                  _priceData!['breakdown']?['averagePerNight'] ??
                  _priceData!['baseRatePerNight'] ??
                  0,
            },
            'dailyBreakdown': _priceData!['dailyBreakdown'] ?? [],
            'priceAfterTax': totalAmount,
            'requestedRooms': _priceData!['requestedRooms'] ?? 1,
            'tax': _priceData!['tax'] ?? [],
            'totalTax': _priceData!['totalTax'] ?? 0,
          }
        : {
            'totalAmount': totalAmount,
            'originalTotalAmount': widget.ratePlan['totalAmount'] ?? 0,
            'numberOfNights': numberOfNights,
            'baseRatePerNight': widget.ratePlan['totalAmount'] ?? 0,
            'additionalGuestCharges': 0,
            'availableRooms': 0,
            'breakdown': {
              'totalBaseAmount': widget.ratePlan['totalAmount'] ?? 0,
              'totalAdditionalCharges': 0,
              'totalAmount': totalAmount,
              'numberOfNights': numberOfNights,
              'averagePerNight': widget.ratePlan['totalAmount'] ?? 0,
            },
            'dailyBreakdown': [],
            'priceAfterTax': totalAmount,
            'requestedRooms': 1,
            'tax': [],
            'totalTax': 0,
          };

    print('Navigating to PaymentPage with propertyId: ${widget.propertyId}');
    print('Discount Applied: ${widget.discountApplied}');
    print('Guest Email: ${_emailController.text}');
    print('Total Amount: $totalAmount');

    Get.to(
      () => PaymentPage(
        priceData: finalPrice,
        paymentData: {},
        bookingDetails: {
          'startDate': widget.startDate,
          'endDate': widget.endDate,
          'propertyCode': widget.propertyCode,
          'hotelName': widget.hotelName,
          'currency': widget.ratePlan['currencyCode'] ?? 'USD',
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'finalPrice': finalPrice,
          'guestDetails': guestDetails,
          'guests': {
            'adults': widget.adults,
            'children': widget.children,
            'rooms': 1,
          },
          'numberOfRooms': 1,
          'promoCode': null,
          'ratePlanCode': widget.ratePlan['ratePlanCode'],
          'roomTypeCode': widget.room['room_type'],
          'room': widget.room,
          'ratePlan': widget.ratePlan,
          'totalGuests': widget.totalGuests,
          'adultsCount': widget.adults,
          'childrenCount': widget.children,
          'discountApplied': widget.discountApplied,
          'discountPercentage': widget.discountApplied ? 10 : 0,
        },
        propertyId: widget.propertyId,
      ),
    );
  }
}
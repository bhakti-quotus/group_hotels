import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/api_controller.dart';
import 'package:group/ui/dialog/dialog.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'price_breakdown_widget.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> priceData;
  final Map<String, dynamic> paymentData;
  final Map<String, dynamic> bookingDetails;
  final String propertyId;

  const PaymentPage({
    Key? key,
    required this.priceData,
    required this.paymentData,
    required this.bookingDetails,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoadingPaymentData = true;
  bool _isUploading = false;
  Map<String, dynamic>? _fetchedPaymentData;
  String? _errorMessage;
  String? _selectedPaymentMethod;
  File? _paymentScreenshot;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingBooking = false;

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    setState(() {
      _isLoadingPaymentData = true;
      _errorMessage = null;
    });

    try {
      final result = await Get.find<ApiController>().fetchPaymentDetails(
        widget.propertyId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _fetchedPaymentData = result['data'];
          _isLoadingPaymentData = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoadingPaymentData = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching payment details';
        _isLoadingPaymentData = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    final messenger = ScaffoldMessenger.of(context);
    Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColor.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _paymentScreenshot = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _paymentScreenshot = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeScreenshot() {
    setState(() {
      _paymentScreenshot = null;
    });
  }

  // Helper method to check if Complete Booking should be enabled
  bool get _isCompleteBookingEnabled {
    if (_isProcessingBooking) return false; // Disable while processing

    if (_selectedPaymentMethod == null) {
      return false; // No payment method selected
    }

    // For Pay at Hotel - enable immediately
    if (_selectedPaymentMethod == 'payAtHotel') {
      return true;
    }

    // For UPI and Bank Transfer - require screenshot upload
    if (_selectedPaymentMethod == 'upi' ||
        _selectedPaymentMethod == 'bankTransfer') {
      return _paymentScreenshot != null;
    }

    // For Gateway payment - enable immediately (no screenshot required)
    if (_selectedPaymentMethod == 'gateway') {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text(
          'Payment Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Breakdown Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: AppColor.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Price Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PriceBreakdownWidget(priceData: widget.priceData),
              ],
            ),

            const SizedBox(height: 24),

            // Payment Options Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: AppColor.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Payment Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isLoadingPaymentData)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchPaymentDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _buildPaymentOptions(),
              ],
            ),

            // Screenshot Upload Section
            if (_selectedPaymentMethod == 'upi' ||
                _selectedPaymentMethod == 'bankTransfer') ...[
              const SizedBox(height: 24),
              _buildScreenshotUploadSection(),
            ],

            const SizedBox(height: 32),

            // Complete Booking Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCompleteBookingEnabled
                    ? _completeBooking
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleteBookingEnabled
                      ? AppColor.primary
                      : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  shadowColor: _isCompleteBookingEnabled
                      ? AppColor.primary.withOpacity(0.3)
                      : Colors.transparent,
                ),
                child: _isProcessingBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _isCompleteBookingEnabled
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Complete Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isCompleteBookingEnabled
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Hint text when button is disabled
            if (!_isCompleteBookingEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Align(
                  child: Text(
                    _getHintText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    if (_isProcessingBooking) {
      return 'Processing your booking...';
    }
    if (_selectedPaymentMethod == null) {
      return 'Please select a payment method to continue';
    } else if ((_selectedPaymentMethod == 'upi' ||
            _selectedPaymentMethod == 'bankTransfer') &&
        _paymentScreenshot == null) {
      return 'Please upload payment screenshot to continue';
    }
    return '';
  }

  Widget _buildPaymentOptions() {
    final paymentData = _fetchedPaymentData ?? widget.paymentData;

    final List<Widget> options = [];

    // Pay at Hotel Option
    if (paymentData['payAtHotel'] == true) {
      options.add(_buildPaymentOptionCard(
        icon: Icons.hotel,
        title: 'Pay at Hotel',
        description:
            'You can pay for your booking directly at the hotel upon arrival.',
        isAvailable: true,
        paymentData: paymentData,
        paymentMethodKey: 'payAtHotel',
      ));
      options.add(const SizedBox(height: 16));
    }

    // UPI Payment Option
    if (paymentData['upi'] == true) {
      options.add(_buildPaymentOptionCard(
        icon: Icons.phone_android,
        title: 'UPI Payment',
        description: 'Pay using UPI apps like Google Pay, PhonePe, etc.',
        isAvailable: true,
        paymentData: paymentData,
        paymentMethodKey: 'upi',
      ));
      options.add(const SizedBox(height: 16));
    }

    // Bank Transfer Option
    if (paymentData['bankTransfer'] == true) {
      options.add(_buildPaymentOptionCard(
        icon: Icons.account_balance,
        title: 'Bank Transfer',
        description: 'Direct bank transfer to the hotel account.',
        isAvailable: true,
        paymentData: paymentData,
        paymentMethodKey: 'bankTransfer',
      ));
      options.add(const SizedBox(height: 16));
    }

    // Gateway Option
    if (paymentData['gateway'] == true) {
      options.add(_buildPaymentOptionCard(
        icon: Icons.credit_card,
        title: 'Online Payment',
        description: 'Secure online payment through payment gateway.',
        isAvailable: true,
        paymentData: paymentData,
        paymentMethodKey: 'gateway',
      ));
    }

    // Remove the last SizedBox if options are not empty
    if (options.isNotEmpty && options.last is SizedBox) {
      options.removeLast();
    }

    return Column(
      children: options,
    );
  }

  Widget _buildPaymentOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isAvailable,
    Map<String, dynamic>? paymentData,
    String? paymentMethodKey,
  }) {
    final isSelected =
        _selectedPaymentMethod == paymentMethodKey && isAvailable;

    return InkWell(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedPaymentMethod = paymentMethodKey;
                // If user switches from UPI/Bank Transfer to another method, clear screenshot
                if ((_selectedPaymentMethod != 'upi' &&
                        _selectedPaymentMethod != 'bankTransfer') ||
                    !isSelected) {
                  _paymentScreenshot = null;
                }
              });
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColor.primary.withOpacity(0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isAvailable ? AppColor.primary : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isAvailable ? AppColor.text : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isAvailable
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected && isAvailable)
                    Icon(Icons.check_circle, color: Colors.green, size: 24)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isAvailable
                              ? Colors.green.shade800
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              if (isSelected && isAvailable && paymentData != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: paymentMethodKey == 'payAtHotel'
                      ? _buildPayAtHotelDetails(paymentData)
                      : paymentMethodKey == 'upi'
                      ? _buildEnhancedUpiDetails(paymentData)
                      : paymentMethodKey == 'bankTransfer'
                      ? _buildBankTransferDetails(paymentData)
                      : paymentMethodKey == 'gateway'
                      ? _buildGatewayDetails(paymentData)
                      : Container(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankTransferDetails(Map<String, dynamic> data) {
    final accountHolder = data['accountHolder'] ?? '';
    final accountNumber = data['accountNumber'] ?? '';
    final ifscCode = data['ifscCode'] ?? '';
    final bankName = data['bankName'] ?? '';
    final amount = (widget.priceData['totalAmount'] ?? 0).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Transfer Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.text,
          ),
        ),
        const SizedBox(height: 12),

        // Account Holder Name
        if (accountHolder.isNotEmpty)
          _buildDetailRow('Account Holder', accountHolder, showCopy: true),

        // Account Number
        if (accountNumber.isNotEmpty)
          _buildDetailRow('Account Number', accountNumber, showCopy: true),

        // IFSC Code
        if (ifscCode.isNotEmpty)
          _buildDetailRow('IFSC Code', ifscCode, showCopy: true),

        // Bank Name
        if (bankName.isNotEmpty)
          _buildDetailRow('Bank Name', bankName, showCopy: false),

        // Amount
        _buildDetailRow('Amount', '₹$amount', showCopy: false),

        const SizedBox(height: 16),

        // Important Note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please upload payment screenshot after transferring',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedUpiDetails(Map<String, dynamic> data) {
    final upiId = data['upiId'] ?? '';
    final name = data['accountHolder'] ?? '';
    final amount = (widget.priceData['totalAmount'] ?? 0).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.text,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('UPI ID', upiId, showCopy: true),
        _buildDetailRow('Payee Name', name, showCopy: false),
        _buildDetailRow('Amount', '₹$amount', showCopy: false),
        const SizedBox(height: 16),

        // QR Code Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _launchUpiApp(upiId, name, amount),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: QrImageView(
                    data:
                        'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=$amount&cu=INR&tn=Hotel Booking',
                    size: 180,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _launchUpiApp(upiId, name, amount),
                icon: const Icon(Icons.payment),
                label: const Text(
                  'Pay with UPI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  iconColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayAtHotelDetails(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Instructions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pay at hotel during check-in. Carry cash or card.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGatewayDetails(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Instructions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.text,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.purple.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will be redirected to a secure payment gateway to complete your payment.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.purple.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool showCopy = false}) {
    final valueText = value?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.text,
                    ),
                  ),
                ),
                if (showCopy && valueText.isNotEmpty)
                  IconButton(
                    onPressed: () => _copyToClipboard(valueText, label),
                    icon: Icon(Icons.copy, size: 18, color: AppColor.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotUploadSection() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload, color: AppColor.primary),
                const SizedBox(width: 10),
                Text(
                  'Payment Proof Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload screenshot of successful payment',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            if (_paymentScreenshot == null)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload Payment Screenshot',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'JPG, PNG (Max 5MB)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _captureImage,
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text(
                                'Camera',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                iconColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library, size: 18),
                              label: Text(
                                'Gallery',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColor.primary),
                                iconColor: AppColor.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_paymentScreenshot!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _removeScreenshot,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(
                          Icons.swap_horiz,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Change',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUpiApp(String upiId, String name, String amount) async {
    final messenger = ScaffoldMessenger.of(context);

    // Ensure amount is > 0
    if (double.tryParse(amount) == null || double.parse(amount) <= 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Invalid payment amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'upi://pay'
      '?pa=$upiId'
      '&pn=${Uri.encodeComponent(name)}'
      '&am=$amount'
      '&cu=INR'
      '&tn=${Uri.encodeComponent("Hotel Booking Payment")}',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to open UPI app')),
      );
    }
  }

  void _completeBooking() async {
    if (!_isCompleteBookingEnabled || _isProcessingBooking) return;

    setState(() {
      _isProcessingBooking = true;
    });

    try {
      final payload = {
        'data': {
          'bankDetails': _fetchedPaymentData,
          'bookingDetails': widget.bookingDetails,
          'guestDetails': widget.bookingDetails['guestDetails'],
          'paymentMethod': _selectedPaymentMethod,
          'paymentScreenshot': _paymentScreenshot != null
              ? base64Encode(await _paymentScreenshot!.readAsBytes())
              : null,
        },
      };

      final result = await Get.find<ApiController>().completeBooking(payload);

      if (!mounted) return;

      if (result['success'] == true) {
        _showBookingSuccessDialog();
      } else {
        setState(() {
          _isProcessingBooking = false;
        });
        showErrorDialog(context, 'Booking failed');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessingBooking = false;
      });
      showErrorDialog(context, 'Booking failed');
    }
  }

  void _showBookingSuccessDialog() {
    showSuccessDialog(
      context,
      'Your booking has been completed successfully.',
      barrierDismissible: false,
      onPressed: () {
        if (mounted) {
          setState(() {
            _isProcessingBooking = false;
          });
        }
        Navigator.pop(context);
        Get.offAllNamed('/rooms', arguments: {'tab': 1});
      },
    );
  }
}
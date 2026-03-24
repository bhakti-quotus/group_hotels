import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group/group/controllers/api_controller.dart';

class CancelBookingPage extends StatefulWidget {
  const CancelBookingPage({super.key});

  @override
  State<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  final TextEditingController _reasonController = TextEditingController();
  final ApiController _apiController = Get.find<ApiController>();
  
  bool _isLoading = false;
  Map<String, dynamic>? _bookingData;

  @override
  void initState() {
    super.initState();
    // Get booking data from arguments
    final args = Get.arguments;
    if (args != null && args['bookingData'] != null) {
      _bookingData = args['bookingData'];
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitCancellation() async {
    if (_bookingData == null) {
      Get.snackbar('Error', 'No booking data found');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the reservation ID from booking data
      final String reservationId = _bookingData!['id'] ?? '';
      
      if (reservationId.isEmpty) {
        Get.snackbar('Error', 'Reservation ID not found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Build cancellation payload
      final Map<String, dynamic> payload = {
        'reason': _reasonController.text.trim(),
        'bookingCode': _bookingData!['bookingCode'] ?? '',
        'roomTypeCode': _bookingData!['roomTypeCode'] ?? '',
        'checkInDate': _bookingData!['checkInDate'] ?? '',
        'checkOutDate': _bookingData!['checkOutDate'] ?? '',
        'amount': _bookingData!['amount'] ?? 0,
        'currencyCode': _bookingData!['currencyCode'] ?? 'USD',
        'propertyId': _bookingData!['propertyId'] ?? '',
        'propertyCode': _bookingData!['propertyCode'] ?? '',
        'hotelName': _bookingData!['hotelName'] ?? '',
        'ratePlanCode': _bookingData!['ratePlanCode'] ?? '',
        'bookedAt': _bookingData!['bookedAt'] ?? '',
        'countryCode': _bookingData!['countryCode'] ?? '',
        'timezone': _bookingData!['timezone'] ?? '',
        'deviceTypes': _bookingData!['deviceTypes'] ?? '',
        'primaryGuestId': _bookingData!['primaryGuestId'] ?? '',
        'guests': _bookingData!['guests'] ?? [],
        'bookingUserEmail': _bookingData!['bookingUserEmail'] ?? '',
        'bookingUserPhone': _bookingData!['bookingUserPhone'] ?? '',
        'finalPrice': _bookingData!['finalPrice'] ?? {},
        'paidAmount': _bookingData!['paidAmount'] ?? 0,
        'extraAmountToPay': _bookingData!['extraAmountToPay'] ?? 0,
        'refundAmount': _bookingData!['refundAmount'] ?? 0,
        'paymentMethod': _bookingData!['paymentMethod'] ?? '',
        'bookingStatus': _bookingData!['bookingStatus'] ?? '',
        'cancellationReason': _reasonController.text.trim(),
        'bookingSource': _bookingData!['bookingSource'] ?? '',
      };

     // print('=== CANCEL BOOKING PAYLOAD ===');
     // print('Reservation ID: $reservationId');
    //  print('Payload: $payload');

      final result = await _apiController.cancelBooking(
        reservationId: reservationId,
        payload: payload,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        Get.back(result: {
          'success': true,
          'cancelled': true,
          'data': result['data'],
        });
        Get.snackbar('Success', 'Booking cancelled successfully');
      } else {
        Get.snackbar('Error', result['error'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancel Booking'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Info Card
            if (_bookingData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Code: ${_bookingData!['bookingCode'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Hotel: ${_bookingData!['hotelName'] ?? ''}'),
                      Text('Room: ${_bookingData!['roomTypeCode'] ?? ''}'),
                      Text('Check-in: ${_bookingData!['checkInDate'] ?? ''}'),
                      Text('Check-out: ${_bookingData!['checkOutDate'] ?? ''}'),
                      Text('Amount: ${_bookingData!['currencyCode'] ?? ''} ${_bookingData!['amount'] ?? 0}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Warning Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Are you sure you want to cancel this booking? This action cannot be undone.',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reason Field
            const Text(
              'Cancellation Reason',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Please enter the reason for cancellation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitCancellation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Confirm Cancellation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


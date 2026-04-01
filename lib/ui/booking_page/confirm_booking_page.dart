import 'package:flutter/material.dart';
import 'package:royalcontinent/group/common/theme/theme.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/models/booking_data_model.dart';

class ConfirmBookingPage extends StatelessWidget {
  const ConfirmBookingPage({Key? key}) : super(key: key);

  BookingDataModel get bookingData => Get.arguments as BookingDataModel;

  int get totalNights =>
      bookingData.checkOut.difference(bookingData.checkIn).inDays;

  int get roomsPrice => bookingData.basePrice * totalNights * bookingData.rooms;

  int get adultsPrice => (bookingData.adults > 1)
      ? (bookingData.adults - 1) * 500 * totalNights
      : 0;

  int get childrenPrice => bookingData.children * 300 * totalNights;

  int get subtotal => roomsPrice + adultsPrice + childrenPrice;

  double get gstAmount => subtotal * 0.12;
  double get serviceTax => subtotal * 0.05;

  double get totalPrice => subtotal + gstAmount + serviceTax;

  @override
  Widget build(BuildContext context) {
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
          'Confirm Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Room Details Card ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColor.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColor.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookingData.roomName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.bed,
                                size: 16,
                                color: AppColor.textLight,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${bookingData.rooms} Room${bookingData.rooms > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColor.textLight,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1),
                          ),
                          // Stay Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Stay Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.text,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Check-In',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${bookingData.checkIn.day}-${bookingData.checkIn.month}-${bookingData.checkIn.year}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppColor.textLight,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Check-Out',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${bookingData.checkOut.day}-${bookingData.checkOut.month}-${bookingData.checkOut.year}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalNights Night${totalNights > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primary,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1),
                          ),
                          // Guest Details
                          Text(
                            'Guest Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.text,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCompactGuestRow(
                            'Adults',
                            bookingData.adults,
                            Icons.person,
                          ),
                          if (bookingData.children > 0) ...[
                            const SizedBox(height: 8),
                            _buildCompactGuestRow(
                              'Children',
                              bookingData.children,
                              Icons.child_care,
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Text(
                                'Ages: ${bookingData.childAges.join(", ")}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColor.textLight,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Price Breakdown ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColor.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColor.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.text,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPriceRow(
                            'AED ${bookingData.basePrice} × $totalNights nights × ${bookingData.rooms} rooms',
                            'AED $roomsPrice',
                          ),
                          if (bookingData.adults > 1) ...[
                            const SizedBox(height: 6),
                            _buildPriceRow(
                              'Additional adults (${bookingData.adults - 1} × AED 500 × $totalNights)',
                              'AED $adultsPrice',
                            ),
                          ],
                          if (bookingData.children > 0) ...[
                            const SizedBox(height: 6),
                            _buildPriceRow(
                              'Children (${bookingData.children} × AED 300 × $totalNights)',
                              'AED $childrenPrice',
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1),
                          ),
                          _buildPriceRow(
                            'Subtotal',
                            'AED $subtotal',
                            isSubtotal: true,
                          ),
                          const SizedBox(height: 6),
                          _buildPriceRow(
                            'GST (12%)',
                            'AED ${gstAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 6),
                          _buildPriceRow(
                            'Service Tax (5%)',
                            'AED ${serviceTax.toStringAsFixed(2)}',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
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
                  ],
                ),
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Your booking has been confirmed successfully.',
                    style: TextStyle(color: AppColor.textLight),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: AppColor.primary),
                      ),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm Booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactGuestRow(String label, int count, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColor.primary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 14, color: AppColor.text)),
        const Spacer(),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
      ],
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
              fontSize: isTotal ? 15 : 12,
              fontWeight: isTotal
                  ? FontWeight.bold
                  : (isSubtotal ? FontWeight.w600 : FontWeight.w500),
              color: isTotal
                  ? AppColor.primary
                  : (isSubtotal ? AppColor.text : AppColor.textLight),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal
                ? FontWeight.bold
                : (isSubtotal ? FontWeight.w600 : FontWeight.w500),
            color: isTotal ? AppColor.primary : AppColor.text,
          ),
        ),
      ],
    );
  }
}

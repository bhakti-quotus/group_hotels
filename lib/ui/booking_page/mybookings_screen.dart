// screens/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:sunswept/group/common/theme/theme.dart';
import 'package:sunswept/group/models/booking_model.dart';
import 'package:sunswept/ui/booking_page/preCheckin_page.dart';

class MyBookingsScreen extends StatefulWidget {
  final List<BookingModel> bookings;
  final Map<String, bool> expandedStates;
  final VoidCallback onRefresh;
  final Function(String code) onToggleExpanded;

  const MyBookingsScreen({
    Key? key,
    required this.bookings,
    required this.expandedStates,
    required this.onRefresh,
    required this.onToggleExpanded,
  }) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final Set<String> _preCheckedInBookings = {};

  @override
  Widget build(BuildContext context) {
    if (widget.bookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      color: AppColor.primary,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.bookings.length,
        itemBuilder: (context, index) {
          final booking = widget.bookings[index];
          final isExpanded =
              widget.expandedStates[booking.bookingCode] ?? false;
          return _buildBookingCard(context, booking, isExpanded);
        },
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 70,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'Start your journey by booking your first room',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, 
                  color: Colors.grey.shade600, 
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BOOKING CARD ----------------
  Widget _buildBookingCard(
    BuildContext context,
    BookingModel booking,
    bool isExpanded,
  ) {
    List<String> guestNames = booking.guestNames
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(booking.bookingStatus),
                    _getStatusColor(booking.bookingStatus).withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.bookingStatus.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${booking.bookingCode}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    booking.totalPriceFormatted,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // DATE ROW
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateCard(
                          'CHECK-IN',
                          booking.formattedCheckIn,
                          Icons.login_rounded,
                          AppColor.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateCard(
                          'CHECK-OUT',
                          booking.formattedCheckOut,
                          Icons.logout_rounded,
                          AppColor.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // INFO CHIPS
                  Row(
                    children: [
                      _buildInfoChip(
                        '${booking.requestedRooms} Room${booking.requestedRooms > 1 ? 's' : ''}',
                        Icons.hotel_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        '${booking.numberOfAdults} Guest${booking.numberOfAdults > 1 ? 's' : ''}',
                        Icons.people_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        booking.duration,
                        Icons.nights_stay_rounded,
                      ),
                    ],
                  ),

                  if (isExpanded) ...[
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 16),

                    // Pre-checkin Button (only for confirmed bookings)
                    if (booking.bookingStatus.toLowerCase() == 'confirmed' &&
                        !_preCheckedInBookings.contains(booking.bookingCode))
                      _buildPreCheckinButton(context, booking),

                    if (booking.bookingStatus.toLowerCase() == 'confirmed' &&
                        !_preCheckedInBookings.contains(booking.bookingCode))
                      const SizedBox(height: 16),

                    if (guestNames.isNotEmpty)
                      _buildSection(
                        'Guests',
                        Icons.people_rounded,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: guestNames
                              .map(
                                (g) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppColor.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        g,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColor.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    if (guestNames.isNotEmpty) const SizedBox(height: 16),

                    _buildSection(
                      'Contact Information',
                      Icons.contact_page_rounded,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  booking.bookingUserEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                booking.bookingUserPhone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Booked on ${booking.formattedBookedAt}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () => widget.onToggleExpanded(booking.bookingCode),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isExpanded ? 'Show Less' : 'View Details',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pre-checkin Button
  Widget _buildPreCheckinButton(BuildContext context, BookingModel booking) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreCheckinPage(booking: booking),
            ),
          );

          if (result == true && mounted) {
            setState(() {
              _preCheckedInBookings.add(booking.bookingCode);
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Pre-checkin completed successfully!'),
                backgroundColor: AppColor.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.how_to_reg_rounded, size: 18),
        label: const Text(
          'Complete Pre-checkin',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ---------------- SMALL WIDGETS ----------------

  Widget _buildDateCard(String label, String date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColor.textLight),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColor.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon, 
                size: 16, 
                color: AppColor.primary,
              ),
            ),
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
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: content,
        ),
      ],
    );
  }

  // ---------------- STATUS COLOR ----------------
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColor.primary;
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'completed':
        return AppColor.secondary;
      default:
        return const Color(0xFF6B7280);
    }
  }
}
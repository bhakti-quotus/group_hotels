import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalcontinent/group/controllers/api_controller.dart';

class CancelBookingPage extends StatefulWidget {
  const CancelBookingPage({super.key});

  @override
  State<CancelBookingPage> createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reasonController = TextEditingController();
  final ApiController _apiController = Get.find<ApiController>();

  bool _isLoading = false;
  bool _showConfirmPanel = false;
  bool _isCancelled = false;
  String? _selectedChip;
  Map<String, dynamic>? _bookingData;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _quickReasons = [
    'Change of plans',
    'Found better option',
    'Emergency',
    'Travel cancelled',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['bookingData'] != null) {
      _bookingData = args['bookingData'];
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? const Color(0xFFA32D2D)
          : const Color(0xFF3B6D11),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: Duration(seconds: isError ? 4 : 3),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Future<void> _submitCancellation() async {
    final reason = _selectedChip != null
        ? _selectedChip!
        : _reasonController.text.trim();

    // Requirement: during cancel, reason is NOT mandatory.
    // If user provided a quick reason chip, use it; otherwise take free text.
    final reasonText = _selectedChip != null ? _selectedChip! : _reasonController.text.trim();

    if (_bookingData == null) {
      _showSnackbar('No booking data found', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Backend might send reservation id under different keys.
      final String reservationId = () {
        String? findInMap(Map<String, dynamic> map) {
          for (final key in ['id', 'reservationId', 'reservation_id']) {
            final v = map[key];
            if (v == null) continue;
            final s = v.toString();
            if (s.isNotEmpty) return s;
          }
          return null;
        }

        // Flat keys (what your list API returns)
        final direct = findInMap(Map<String, dynamic>.from(_bookingData!));
        if (direct != null && direct.isNotEmpty) return direct;

        // Common nested shapes from detail APIs: { data: { id } } or { reservation: { id } }
        final data = _bookingData!['data'];
        if (data is Map<String, dynamic>) {
          final nested = findInMap(data);
          if (nested != null && nested.isNotEmpty) return nested;
        }

        final reservation = _bookingData!['reservation'];
        if (reservation is Map<String, dynamic>) {
          final nested = findInMap(reservation);
          if (nested != null && nested.isNotEmpty) return nested;
        }

        // Last resort: look for any nested key named like an id
        for (final key in ['id', 'reservationId', 'reservation_id']) {
          final v = _bookingData![key];
          if (v != null) {
            final s = v.toString();
            if (s.isNotEmpty) return s;
          }
        }

        return '';
      }();

      if (reservationId.isEmpty) {
        _showSnackbar(
          'Reservation ID not found in booking data',
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      // If user didn't enter/select anything, send a default reason.
      final details = _reasonController.text.trim();
      final fullReason = details.isNotEmpty ? '$reasonText — $details' : reasonText;

      final Map<String, dynamic> payload = {
        'reason': fullReason,
        'cancellationReason': fullReason,
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
        'bookingSource': _bookingData!['bookingSource'] ?? '',
      };

      final result = await _apiController.cancelBooking(
        reservationId: reservationId,
        payload: payload,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        setState(() {
          _showConfirmPanel = false;
          _isCancelled = true;
        });
        Future.delayed(const Duration(milliseconds: 1800), () {
          Get.back(
            result: {
              'success': true,
              'cancelled': true,
              'data': result['data'],
            },
          );
          _showSnackbar('Booking cancelled successfully');
        });
      } else {
        _showSnackbar(
          result['error'] ?? 'Failed to cancel booking',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('An unexpected error occurred', isError: true);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F3),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(colorScheme),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_bookingData != null) ...[
                            _BookingCard(bookingData: _bookingData!),
                            const SizedBox(height: 14),
                          ],
                          _CancellationNoticeCard(),
                          const SizedBox(height: 14),
                          _RefundSummaryCard(bookingData: _bookingData),
                          const SizedBox(height: 14),
                          _ReasonCard(
                            quickReasons: _quickReasons,
                            selectedChip: _selectedChip,
                            controller: _reasonController,
                            onChipSelected: (v) =>
                                setState(() => _selectedChip = v),
                          ),
                          const SizedBox(height: 20),
                          if (_isCancelled)
                            _SuccessBanner()
                          else if (_showConfirmPanel)
                            _ConfirmPanel(
                              bookingCode: _bookingData?['bookingCode'] ?? '—',
                              refundAmount:
                                  _bookingData?['refundAmount']?.toString() ??
                                  '0',
                              currencyCode:
                                  _bookingData?['currencyCode'] ?? 'USD',
                              onCancel: () =>
                                  setState(() => _showConfirmPanel = false),
                              onConfirm: _submitCancellation,
                            )
                          else
                            _ActionButtons(
                              onRequest: () {
                                final reason = _selectedChip != null
                                    ? _selectedChip!
                                    : _reasonController.text.trim();
                                if (reason.isEmpty) {
                                  _showSnackbar(
                                    'Please select or enter a reason',
                                    isError: true,
                                  );
                                  return;
                                }
                                setState(() => _showConfirmPanel = true);
                              },
                              onBack: () => Get.back(),
                            ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(child: _LoadingIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1C1B1F),
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: const Color(0x22000000)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFCEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: Color(0xFFA32D2D),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancel booking',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1B1F),
                ),
              ),
              Text(
                'Review and confirm cancellation',
                style: TextStyle(fontSize: 11, color: Color(0xFF79777C)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Date Formatter ───────────────────────────────────────────────────────────

String formatBookingDate(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  try {
    final dt = DateTime.parse(raw);
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) {
    return raw;
  }
}

// ─── Booking Info Card ────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  const _BookingCard({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            label: 'Booking details',
            trailing: _StatusBadge(label: 'Confirmed', isSuccess: true),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: Color(0xFF185FA5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingData['hotelName'] ?? '—',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1B1F),
                      ),
                    ),
                    Text(
                      'Code: ${bookingData['bookingCode'] ?? '—'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF79777C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Check-in',
                  value: formatBookingDate(bookingData['checkInDate']),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  label: 'Check-out',
                  value: formatBookingDate(bookingData['checkOutDate']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Room type',
                  value: bookingData['roomTypeCode'] ?? '—',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  label: 'Guests',
                  value: bookingData['guests'] is List
                      ? '${(bookingData['guests'] as List).length} guests'
                      : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F5F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total paid',
                  style: TextStyle(fontSize: 13, color: Color(0xFF79777C)),
                ),
                Text(
                  '${bookingData['currencyCode'] ?? 'USD'} ${bookingData['amount'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cancellation Notice ──────────────────────────────────────────────────────

class _CancellationNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFAC775), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF854F0B),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cancellation notice',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF633806),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Cancellation within 48 hours of check-in may be non-refundable. This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF854F0B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Refund Summary ───────────────────────────────────────────────────────────

class _RefundSummaryCard extends StatelessWidget {
  final Map<String, dynamic>? bookingData;
  const _RefundSummaryCard({this.bookingData});

  @override
  Widget build(BuildContext context) {
    final currency = bookingData?['currencyCode'] ?? 'USD';
    final paid = bookingData?['paidAmount'] ?? 0;
    final refund = bookingData?['refundAmount'] ?? 0;
    final fee = (paid is num && refund is num) ? (paid - refund) : 0;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(label: 'Estimated refund'),
          const SizedBox(height: 12),
          _RefundRow(label: 'Amount paid', value: '$currency $paid'),
          const SizedBox(height: 8),
          _RefundRow(
            label: 'Cancellation fee',
            value: '− $currency $fee',
            valueColor: const Color(0xFFA32D2D),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 0.5, color: Color(0x22000000)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Refund amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1B1F),
                ),
              ),
              Text(
                '$currency $refund',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B6D11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Refund will be processed within 5–7 business days.',
            style: TextStyle(fontSize: 12, color: Color(0xFF79777C)),
          ),
        ],
      ),
    );
  }
}

class _RefundRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _RefundRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF79777C)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? const Color(0xFF1C1B1F),
          ),
        ),
      ],
    );
  }
}

// ─── Reason Card ─────────────────────────────────────────────────────────────

class _ReasonCard extends StatelessWidget {
  final List<String> quickReasons;
  final String? selectedChip;
  final TextEditingController controller;
  final ValueChanged<String> onChipSelected;

  const _ReasonCard({
    required this.quickReasons,
    required this.selectedChip,
    required this.controller,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _CardHeader(label: 'Reason for cancellation'),
              SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFA32D2D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickReasons.map((r) {
              final selected = selectedChip == r;
              return GestureDetector(
                onTap: () => onChipSelected(r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFCEBEB)
                        : const Color(0xFFF6F5F3),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFA32D2D)
                          : const Color(0xFFD3D1C7),
                      width: selected ? 1 : 0.5,
                    ),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? const Color(0xFFA32D2D)
                          : const Color(0xFF5F5E5A),
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 300,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1C1B1F)),
            decoration: InputDecoration(
              hintText: 'Add additional details (optional)...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB4B2A9),
              ),
              filled: true,
              fillColor: const Color(0xFFF6F5F3),
              counterStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFFB4B2A9),
              ),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFD3D1C7),
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFD3D1C7),
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF888780),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Panel ────────────────────────────────────────────────────────────

class _ConfirmPanel extends StatelessWidget {
  final String bookingCode;
  final String refundAmount;
  final String currencyCode;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmPanel({
    required this.bookingCode,
    required this.refundAmount,
    required this.currencyCode,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7C1C1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm cancellation?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA32D2D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You are about to cancel booking $bookingCode. '
            'A refund of $currencyCode $refundAmount will be processed within 5–7 business days.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFA32D2D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA32D2D),
                    side: const BorderSide(
                      color: Color(0xFFA32D2D),
                      width: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Go back', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA32D2D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Yes, cancel',
                    style: TextStyle(fontSize: 13),
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

// ─── Success Banner ───────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC0DD97), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF3B6D11),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Booking cancelled',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B6D11),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your refund is being processed and will arrive in 5–7 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF3B6D11),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final VoidCallback onRequest;
  final VoidCallback onBack;
  const _ActionButtons({required this.onRequest, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA32D2D),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Request cancellation',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5F5E5A),
              side: const BorderSide(color: Color(0xFFD3D1C7), width: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Keep my booking',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Components ────────────────────────────────────────────────────────

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22000000), width: 0.5),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _CardHeader({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888780),
            letterSpacing: 0.05,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isSuccess;
  const _StatusBadge({required this.label, this.isSuccess = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isSuccess ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1B1F),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA32D2D)),
          ),
          SizedBox(height: 14),
          Text(
            'Processing cancellation...',
            style: TextStyle(fontSize: 13, color: Color(0xFF5F5E5A)),
          ),
        ],
      ),
    );
  }
}

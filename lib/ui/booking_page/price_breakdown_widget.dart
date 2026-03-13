import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

class PriceBreakdownWidget extends StatefulWidget {
  final Map<String, dynamic> priceData;

  /// GlobalKey attached to the info icon in the parent header.
  /// Used to position the popup right below that icon.
  final GlobalKey? infoIconKey;

  const PriceBreakdownWidget({
    Key? key,
    required this.priceData,
    this.infoIconKey,
  }) : super(key: key);

  @override
  State<PriceBreakdownWidget> createState() => PriceBreakdownWidgetState();
}

// Public state so the parent can call showPriceDetailsPopup directly.
class PriceBreakdownWidgetState extends State<PriceBreakdownWidget> {
  bool _showDailyBreakdown = false;
  bool _showTaxBreakdown = false;
  bool _showAddonBreakdown = false;
  bool _showPromotionBreakdown = false;

  // Simple helper to safely get double values - NO CALCULATIONS, just casting
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ─── Public: called by parent's info-icon tap ─────────────────────────────
  void showPriceDetailsPopup(BuildContext context) {
    final key = widget.infoIconKey;
    if (key?.currentContext == null) return;

    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    final d = widget.priceData;
    final currency = d['currencyCode'] ?? 'USD';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (_) => Stack(
        children: [
          Positioned(
            top: offset.dy + size.height + 8,
            right: MediaQuery.of(context).size.width - offset.dx - size.width,
            child: Material(
              color: Colors.transparent,
              child: _PriceDetailsPopup(
                priceData: d, // Pass the entire priceData
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final d = widget.priceData;
    final currency = d['currencyCode'] ?? 'USD';
    
    // Get values directly from API - NO CALCULATIONS
    final amountBeforeTax = _toDouble(d['amountBeforeTax']);
    final totalAmount = _toDouble(d['totalAmount']);
    final taxedAmount = _toDouble(d['taxedAmount']);
    final currentChargeableAmount = _toDouble(d['currentChargeableAmount']);
    final loyalityDiscount = _toDouble(d['loyalityDiscount']);
    final totalAddonAmt = _toDouble(d['totalAddonAmount']);
    
    // Get arrays directly from API
    final taxBreakdown = d['taxBrakeDown'] as List? ?? [];
    final addonBreakdown = d['addonBrakeDown'] as List? ?? [];
    final promotionBreakdown = d['promotionBrakeDown'] as List? ?? [];
    final dailyBreakdown = d['dailyPriceBrakeDown'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Base Amount ────────────────────────────────────────────────────
        _buildLineItem(
          label: 'Base Amount',
          sublabel: 'Before taxes & fees',
          value: '$currency ${amountBeforeTax.toStringAsFixed(2)}',
        ),
        const _DashedDivider(),

        // ── Loyalty Discount (if any) ──────────────────────────────────────
        if (loyalityDiscount > 0) ...[
          _buildLineItem(
            label: 'Loyalty Discount',
            sublabel: 'Applied to your stay',
            value: '-$currency ${loyalityDiscount.toStringAsFixed(2)}',
            valueColor: Colors.green.shade700,
          ),
          const _DashedDivider(),
        ],

        // ── Add-ons ─────────────────────────────────────────────────────
        if (addonBreakdown.isNotEmpty) ...[
          _buildExpandable(
            title: 'Add-ons',
            trailingValue: '+$currency ${totalAddonAmt.toStringAsFixed(2)}',
            trailingColor: const Color(0xFF4A5568),
            isExpanded: _showAddonBreakdown,
            onTap: () =>
                setState(() => _showAddonBreakdown = !_showAddonBreakdown),
            children: addonBreakdown.map<Widget>((a) {
              return _buildSubItem(
                label: a['name'] ?? 'Add-on',
                value: '$currency ${_toDouble(a['amount']).toStringAsFixed(2)}',
              );
            }).toList(),
          ),
          const _DashedDivider(),
        ],

        // ── Taxes & Fees ───────────────────────────────────────────────────
        if (taxBreakdown.isNotEmpty) ...[
          _buildExpandable(
            title: 'Taxes & Fees',
            trailingValue: '+$currency ${taxedAmount.toStringAsFixed(2)}',
            trailingColor: const Color(0xFF4A5568),
            isExpanded: _showTaxBreakdown,
            onTap: () => setState(() => _showTaxBreakdown = !_showTaxBreakdown),
            children: taxBreakdown.map<Widget>((t) {
              final name = t['name'] as String? ?? '';
              return _buildSubItem(
                label: name,
                value: '$currency ${_toDouble(t['taxedAmount']).toStringAsFixed(2)}',
              );
            }).toList(),
          ),
          const _DashedDivider(),
        ],

        // ── Promotions ────────────────────────────────────────────────────
        if (promotionBreakdown.isNotEmpty) ...[
          _buildExpandable(
            title: 'Promotions & Fees',
            trailingValue: '',
            trailingColor: const Color(0xFF4A5568),
            isExpanded: _showPromotionBreakdown,
            onTap: () => setState(
              () => _showPromotionBreakdown = !_showPromotionBreakdown,
            ),
            children: promotionBreakdown.map<Widget>((p) {
              final name = p['name'] as String? ?? '';
              final discountAmount = _toDouble(p['discountAmount']);
              final restrictionType = p['restrictionType'] as String? ?? '';
              final isPayLater = restrictionType == 'payLater';
              
              return _buildSubItem(
                label: name,
                sublabel: isPayLater ? 'Pay at hotel' : null,
                value: isPayLater
                    ? '$currency ${discountAmount.toStringAsFixed(2)}'
                    : '-$currency ${discountAmount.toStringAsFixed(2)}',
                valueColor: isPayLater
                    ? const Color(0xFF4A5568)
                    : Colors.green.shade700,
              );
            }).toList(),
          ),
          const _DashedDivider(),
        ],

        // ── Daily Breakdown ────────────────────────────────────────────────
        if (dailyBreakdown.isNotEmpty) ...[
          _buildExpandable(
            title: 'Daily Breakdown',
            trailingValue: '${dailyBreakdown.length} night${dailyBreakdown.length > 1 ? 's' : ''}',
            trailingColor: const Color(0xFF4A5568),
            isExpanded: _showDailyBreakdown,
            onTap: () =>
                setState(() => _showDailyBreakdown = !_showDailyBreakdown),
            children: dailyBreakdown
                .map<Widget>(
                  (day) => _buildDayItem(
                    date: day['date'] ?? '',
                    base: _toDouble(day['baseChargesAmount']),
                    total: _toDouble(day['totalAmount']),
                    currency: currency,
                  ),
                )
                .toList(),
          ),
          const _DashedDivider(),
        ],

        const SizedBox(height: 12),

        // ── Current Chargeable Amount ────────────────────────────────────
        _buildGrandTotal(
          currency,
          currentChargeableAmount,
          sublabel: currentChargeableAmount != totalAmount
              ? 'Includes promotions & fees'
              : null,
        ),
      ],
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  Widget _buildLineItem({
    required String label,
    String? sublabel,
    required String value,
    Color valueColor = const Color(0xFF1A2236),
    IconData? icon,
    Color? iconColor,
    Color? iconBg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg ?? Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2236),
                  ),
                ),
                if (sublabel != null)
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A94A6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandable({
    required String title,
    required String trailingValue,
    required Color trailingColor,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2236),
                    ),
                  ),
                ),
                if (trailingValue.isNotEmpty)
                  Text(
                    trailingValue,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: trailingColor,
                    ),
                  ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFF8A94A6),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEF0F4)),
                  ),
                  child: Column(children: children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubItem({
    required String label,
    required String value,
    String? sublabel,
    Color valueColor = const Color(0xFF4A5568),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFCBD0DC),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A5568),
                  ),
                ),
                if (sublabel != null)
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({
    required String date,
    required double base,
    required double total,
    required String currency,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Base: $currency ${base.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A94A6)),
            ),
          ),
          Text(
            '$currency ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotal(String currency, double total, {String? sublabel}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ],
          ),
          Text(
            '$currency ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Popup ─────────────────────────────────────────────────────────────────────
class _PriceDetailsPopup extends StatelessWidget {
  final Map<String, dynamic> priceData;

  const _PriceDetailsPopup({
    required this.priceData,
  });

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final currency = priceData['currencyCode'] ?? 'USD';
    final amountBeforeTax = _toDouble(priceData['amountBeforeTax']);
    final totalAddonAmount = _toDouble(priceData['totalAddonAmount']);
    final taxedAmount = _toDouble(priceData['taxedAmount']);
    final totalAmount = _toDouble(priceData['totalAmount']);
    final currentChargeableAmount = _toDouble(priceData['currentChargeableAmount']);
    
    final taxBreakdown = priceData['taxBrakeDown'] as List? ?? [];
    final addonBreakdown = priceData['addonBrakeDown'] as List? ?? [];
    final promotionBreakdown = priceData['promotionBrakeDown'] as List? ?? [];

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFEEF0F4))),
            ),
            child: Row(
              children: [
                const Text(
                  'Price Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2236),
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0F4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow(
                  'Base Amount',
                  '$currency ${amountBeforeTax.toStringAsFixed(2)}',
                  isFirst: true,
                ),
                if (addonBreakdown.isNotEmpty) ...[
                  _buildRow(
                    'Add-ons',
                    '+$currency ${totalAddonAmount.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF4A5568),
                  ),
                  ...addonBreakdown.map((a) {
                    return _buildSubRow(
                      a['name'] ?? '',
                      '$currency ${_toDouble(a['amount']).toStringAsFixed(2)}',
                    );
                  }),
                ],
                if (taxedAmount > 0)
                  _buildRow(
                    'Taxes & Fees',
                    '+$currency ${taxedAmount.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF4A5568),
                  ),
                ...taxBreakdown.map(
                  (t) => _buildSubRow(
                    t['name'] ?? '',
                    '$currency ${_toDouble(t['taxedAmount']).toStringAsFixed(2)}',
                  ),
                ),
                if (promotionBreakdown.isNotEmpty) ...[
                  _buildRow(
                    'Promotions & Fees',
                    '',
                    valueColor: const Color(0xFF4A5568),
                  ),
                  ...promotionBreakdown.map((p) {
                    final name = p['name'] ?? '';
                    final amount = _toDouble(p['discountAmount']);
                    final isPayLater = p['restrictionType'] == 'payLater';
                    return _buildSubRow(
                      name,
                      isPayLater
                          ? '+$currency ${amount.toStringAsFixed(2)}'
                          : '-$currency ${amount.toStringAsFixed(2)}',
                      valueColor: isPayLater
                          ? const Color(0xFF4A5568)
                          : Colors.green.shade700,
                    );
                  }),
                ],
                const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFEEF0F4)),
                const SizedBox(height: 10),
                _buildTotalRow(
                  'Current Payable',
                  '$currency ${currentChargeableAmount.toStringAsFixed(2)}',
                  isMainTotal: true,
                ),
                const SizedBox(height: 4),
                _buildTotalRow(
                  'Total (before fees)',
                  '$currency ${totalAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    String? sublabel,
    Color valueColor = const Color(0xFF1A2236),
    bool isFirst = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A5568),
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A94A6),
                  ),
                ),
            ],
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubRow(String label, String value, {Color valueColor = const Color(0xFF8A94A6)}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 7),
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD0DC),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A94A6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isMainTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMainTotal ? 14 : 12,
            fontWeight: isMainTotal ? FontWeight.w800 : FontWeight.w500,
            color: isMainTotal ? const Color(0xFF1A2236) : const Color(0xFF8A94A6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isMainTotal ? 16 : 12,
            fontWeight: isMainTotal ? FontWeight.w800 : FontWeight.w500,
            color: isMainTotal ? AppColor.primary : const Color(0xFF8A94A6),
          ),
        ),
      ],
    );
  }
}

// ─── Dashed Divider ────────────────────────────────────────────────────────────
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: 4,
                height: 1,
                color: const Color(0xFFE8EAF0),
              ),
            ),
          ),
        );
      },
    );
  }
}
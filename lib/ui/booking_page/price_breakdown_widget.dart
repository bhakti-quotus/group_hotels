import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PriceBreakdownWidget
//
// • No internal header — the parent's _buildRoyalCard provides the header.
// • Accepts [infoIconKey] so the parent can trigger [showPriceDetailsPopup]
//   from the info icon it renders inside _buildRoyalCard's header row.
//
// Usage in parent:
//
//   final _priceInfoKey = GlobalKey();
//   final _priceWidgetKey = GlobalKey<_PriceBreakdownWidgetState>();  // optional
//
//   Widget _buildPriceSummaryCard() {
//     return _buildRoyalCard(
//       sectionTitle: 'PRICE SUMMARY',
//       sectionIcon: Icons.receipt_long_outlined,
//       trailingAction: GestureDetector(           // ← pass this
//         key: _priceInfoKey,
//         onTap: () => _priceWidget.showPriceDetailsPopup(context),
//         child: Container(
//           width: 30, height: 30,
//           decoration: BoxDecoration(
//             color: AppColor.primary.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(Icons.info_outline_rounded,
//               size: 16, color: AppColor.primary),
//         ),
//       ),
//       child: PriceBreakdownWidget(
//         key: _priceWidget,
//         priceData: widget.priceData,
//         infoIconKey: _priceInfoKey,
//       ),
//     );
//   }
// ─────────────────────────────────────────────────────────────────────────────

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

  double _d(dynamic v, [double fallback = 0]) =>
      (v as num?)?.toDouble() ?? fallback;

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
                currencyCode: currency,
                amountBeforeTax: _d(d['amountBeforeTax']),
                totalAddonAmount: _d(d['totalAddonAmount']),
                taxedAmount: _d(d['taxedAmount']),
                latterPayableAmount: _d(d['latterpayableAmount']),
                totalAmount: _d(d['totalAmount']),
                taxBreakdown: d['taxBrakeDown'] as List? ?? [],
                addonBreakdown: d['addonBrakeDown'] as List? ?? [],
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
    final amountBeforeTax = _d(d['amountBeforeTax']);
    final totalAmount = _d(d['totalAmount']);
    final taxedAmount = _d(d['taxedAmount']);
    final latterPayableAmount = _d(d['latterpayableAmount']);
    final totalAddonAmt = _d(d['totalAddonAmount']);
    final taxBreakdown = d['taxBrakeDown'] as List? ?? [];
    final addonBreakdown = d['addonBrakeDown'] as List? ?? [];
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

        // ── Privileges ─────────────────────────────────────────────────────
        if (addonBreakdown.isNotEmpty || totalAddonAmt > 0) ...[
          _buildExpandable(
            title: 'Add-ons',
            trailingValue: '+$currency ${totalAddonAmt.toStringAsFixed(2)}',
            trailingColor: const Color(0xFF4A5568),
            isExpanded: _showAddonBreakdown,
            onTap: () =>
                setState(() => _showAddonBreakdown = !_showAddonBreakdown),
            children: addonBreakdown.map<Widget>((a) {
              final qty = _d(a['quantity'], 1);
              final amt = _d(a['totalAmount']) > 0
                  ? _d(a['totalAmount'])
                  : _d(a['amount']) * qty;
              return _buildSubItem(
                label: a['name'] ?? 'Add-on',
                sublabel: qty > 1 ? 'Qty: ${qty.toInt()}' : null,
                value: '$currency ${amt.toStringAsFixed(2)}',
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
                value: '$currency ${_d(t['taxedAmount']).toStringAsFixed(2)}',
                highlight: name == 'Municipality Fee',
              );
            }).toList(),
          ),
          const _DashedDivider(),
        ],

        // ── Daily Breakdown ────────────────────────────────────────────────
        if (dailyBreakdown.isNotEmpty) ...[
          _buildExpandable(
            title: 'Daily Breakdown',
            trailingValue: '${dailyBreakdown.length} nights',
            trailingColor: const Color(0xFF4A5568),
            isExpanded: _showDailyBreakdown,
            onTap: () =>
                setState(() => _showDailyBreakdown = !_showDailyBreakdown),
            children: dailyBreakdown
                .map<Widget>(
                  (day) => _buildDayItem(
                    date: day['date'] ?? '',
                    base: _d(day['baseChargesAmount']),
                    total: _d(day['totalAmount']),
                    currency: currency,
                  ),
                )
                .toList(),
          ),
          const _DashedDivider(),
        ],

        // ── Tourism Fee ────────────────────────────────────────────────────
        if (latterPayableAmount > 0) ...[
          _buildLineItem(
            label: 'Tourism Fee',
            sublabel: 'Payable at hotel',
            value: '$currency ${latterPayableAmount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF4A5568),
          ),
          const _DashedDivider(),
        ],

        const SizedBox(height: 12),

        // ── Grand Total ────────────────────────────────────────────────────
        _buildGrandTotal(currency, totalAmount),
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
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: highlight
                  ? const Color(0xFF6B7280)
                  : const Color(0xFFCBD0DC),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: highlight
                        ? const Color(0xFF374151)
                        : const Color(0xFF4A5568),
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
              color: highlight
                  ? const Color(0xFF374151)
                  : const Color(0xFF4A5568),
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

  Widget _buildGrandTotal(String currency, double total) {
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
            children: const [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Taxes & fees included',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
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
  final String currencyCode;
  final double amountBeforeTax;
  final double totalAddonAmount;
  final double taxedAmount;
  final double latterPayableAmount;
  final double totalAmount;
  final List taxBreakdown;
  final List addonBreakdown;

  const _PriceDetailsPopup({
    required this.currencyCode,
    required this.amountBeforeTax,
    required this.totalAddonAmount,
    required this.taxedAmount,
    required this.latterPayableAmount,
    required this.totalAmount,
    required this.taxBreakdown,
    required this.addonBreakdown,
  });

  double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
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
                _row(
                  'Base Amount',
                  '$currencyCode ${amountBeforeTax.toStringAsFixed(2)}',
                  isFirst: true,
                ),
                if (addonBreakdown.isNotEmpty) ...[
                  _row(
                    'Add-ons',
                    '+$currencyCode ${totalAddonAmount.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF4A5568),
                  ),
                  ...addonBreakdown.map((a) {
                    final qty = _d(a['quantity']);
                    final amt = _d(a['totalAmount']) > 0
                        ? _d(a['totalAmount'])
                        : _d(a['amount']) * (qty > 0 ? qty : 1);
                    return _subRow(
                      a['name'] ?? '',
                      '$currencyCode ${amt.toStringAsFixed(2)}',
                    );
                  }),
                ],
                if (taxedAmount > 0)
                  _row(
                    'Taxes & Fees',
                    '+$currencyCode ${taxedAmount.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF4A5568),
                  ),
                ...taxBreakdown.map(
                  (t) => _subRow(
                    t['name'] ?? '',
                    '$currencyCode ${_d(t['taxedAmount']).toStringAsFixed(2)}',
                  ),
                ),
                if (latterPayableAmount > 0)
                  _row(
                    'Tourism Fee',
                    '$currencyCode ${latterPayableAmount.toStringAsFixed(2)}',
                    sublabel: 'Pay at hotel',
                    valueColor: const Color(0xFF4A5568),
                  ),
                const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFEEF0F4)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2236),
                      ),
                    ),
                    Text(
                      '$currencyCode ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColor.primary,
                      ),
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

  Widget _row(
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

  Widget _subRow(String label, String value) {
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

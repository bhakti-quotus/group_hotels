import 'package:flutter/material.dart';
import 'package:group/group/common/theme/theme.dart';

class PriceBreakdownWidget extends StatefulWidget {
  final Map<String, dynamic> priceData;

  const PriceBreakdownWidget({Key? key, required this.priceData})
    : super(key: key);

  @override
  State<PriceBreakdownWidget> createState() => _PriceBreakdownWidgetState();
}

class _PriceBreakdownWidgetState extends State<PriceBreakdownWidget> {
  bool _showDailyRates = false;

  @override
  Widget build(BuildContext context) {
    final breakdown = widget.priceData['breakdown'] as Map<String, dynamic>?;
    final dailyBreakdown = widget.priceData['dailyBreakdown'] as List?;
    final totalTax = widget.priceData['totalTax'] ?? 0;
    final currencyCode = widget.priceData['currencyCode'] ?? 'USD';

    return Column(
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPriceRow('Base Rate', breakdown?['totalBaseAmount'] ?? 0, currencyCode),
              const SizedBox(height: 4),
              _buildPriceRow(
                'Additional Charges',
                breakdown?['totalAdditionalCharges'] ?? 0,
                currencyCode,
              ),
              const SizedBox(height: 4),
              _buildPriceRow('Taxes & Fees', totalTax, currencyCode),
              const Divider(height: 20, thickness: 1),
              _buildPriceRow(
                'Total Amount',
                widget.priceData['totalAmount'] ?? 0,
                currencyCode,
                isTotal: true,
              ),
            ],
          ),
        ),

        // Daily breakdown with expandable section
        if (dailyBreakdown != null && dailyBreakdown.isNotEmpty) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              setState(() {
                _showDailyRates = !_showDailyRates;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppColor.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Rate Breakdown',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColor.text,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _showDailyRates
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColor.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable daily rates
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showDailyRates
                ? Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: dailyBreakdown.asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final breakdown =
                            day['breakdown'] as Map<String, dynamic>?;
                        final baseAmount = breakdown?['totalBaseAmount'] ?? day['totalPerRoom'] ?? 0;
                        final additionalCharges =
                            breakdown?['totalAdditionalCharges'] ?? 0;
                        final dayCurrency = day['currencyCode'] ?? currencyCode;

                        return Container(
                          margin: EdgeInsets.only(
                            bottom: index < dailyBreakdown.length - 1 ? 8 : 0,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColor.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Day ${index + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(day['date'] ?? ''),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$dayCurrency ${baseAmount.toInt()}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                ],
                              ),
                              if (additionalCharges > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Additional Charges',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '$dayCurrency $additionalCharges',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],

        // Note about taxes
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All taxes and fees are included in the total amount',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, dynamic amount, String currency, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? AppColor.text : Colors.grey[700],
          ),
        ),
        Text(
          '$currency ${amount.toInt()}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? AppColor.primary : AppColor.text,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
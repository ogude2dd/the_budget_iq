import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<DateTime> months;
  final Map<DateTime, double> totals;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;

  const MonthlyBarChart({
    super.key,
    required this.months,
    required this.totals,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  // Single-letter labels for 12 months.
  String _letterFor(int month) {
    const letters = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return letters[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Find the max total so we can scale bar heights proportionally.
    final maxTotal = totals.values.fold<double>(
      0,
          (max, v) => v > max ? v : max,
    );

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: months.map((m) {
          final total = totals[m] ?? 0;
          // Bar height as a fraction of maxTotal.
          // Multiply by 140 (max bar height) and ensure a tiny minimum
          // for non-zero months so the bar is still visible.
          final barHeight = maxTotal == 0
              ? 0.0
              : (total / maxTotal) * 140.0;
          final isSelected = m.year == selectedMonth.year &&
              m.month == selectedMonth.month;

          return Expanded(
            child: GestureDetector(
              onTap: () => onMonthSelected(m),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // The bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: barHeight < 4 && total > 0 ? 4 : barHeight,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6366F1) // indigo for selected
                          : const Color(0xFFE5E7EB), // light gray for others
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Month letter label
                  Text(
                    _letterFor(m.month),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF111827)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
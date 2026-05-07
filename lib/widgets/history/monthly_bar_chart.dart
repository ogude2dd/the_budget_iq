import 'package:flutter/material.dart';
import 'package:the_budget_iq/models/date_range.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<ChartBar> bars;
  final int selectedIndex;
  final ValueChanged<int>? onBarTapped;

  const MonthlyBarChart({
    super.key,
    required this.bars,
    required this.selectedIndex,
    this.onBarTapped,
  });

  @override
  Widget build(BuildContext context) {
    final maxTotal = bars.fold<double>(
      0,
          (max, b) => b.total > max ? b.total : max,
    );

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.asMap().entries.map((entry) {
          final i = entry.key;
          final bar = entry.value;

          final barHeight = maxTotal == 0
              ? 0.0
              : (bar.total / maxTotal) * 140.0;

          // 🆕 RE-ADDED — `isSelected` flag for indigo highlight + bold label
          final isSelected = i == selectedIndex;

          Widget barColumn = Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 140,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Faint full-height track placeholder.
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    // 🔄 CHANGED — Bar color now reflects selection state.
                    // Indigo when this bar is selected, gray otherwise.
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height:
                      barHeight < 4 && bar.total > 0 ? 4 : barHeight,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1) // indigo when selected
                            : const Color(0xFF9CA3AF), // gray otherwise
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 🔄 CHANGED — Selected label is bold + dark for emphasis.
              Text(
                bar.label,
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
          );

          if (onBarTapped != null) {
            barColumn = GestureDetector(
              onTap: () => onBarTapped!(i),
              behavior: HitTestBehavior.opaque,
              child: barColumn,
            );
          }

          return Expanded(child: barColumn);
        }).toList(),
      ),
    );
  }
}
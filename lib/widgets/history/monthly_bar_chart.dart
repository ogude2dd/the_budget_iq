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
    // Find the max total so we can scale heights proportionally.
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

          // Height as a fraction of maxTotal, clamped to a minimum so
          // very small bars are still visible.
          final barHeight = maxTotal == 0
              ? 0.0
              : (bar.total / maxTotal) * 140.0;

          // 🗑️ REMOVED — `isSelected` is no longer needed since bars
          // are uniformly colored regardless of selection.
          // (Keeping `selectedIndex` and `onBarTapped` since taps still
          // work — they just don't visually highlight anymore.)

          Widget barColumn = Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Each bar sits in a fixed-height stack so empty bars
              // still occupy the same space (track placeholder shows).
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

                    // 🔄 CHANGED — Bars are now uniformly medium gray.
                    // The chart is purely informational — bar height conveys
                    // spending, and color uniformity keeps the focus on
                    // heights instead of highlighting any single bar.
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height:
                      barHeight < 4 && bar.total > 0 ? 4 : barHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CA3AF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 🔄 CHANGED — Labels are uniform too. Same weight and color
              // for every bar — no more "selected" emphasis since the color
              // highlight is gone. Selected month appears in the subtitle
              // (e.g. "May 2026") rather than being highlighted on the chart.
              Text(
                bar.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          );

          // Only attach a GestureDetector if bars are tappable.
          // Taps still work, but they don't change the bar's color.
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
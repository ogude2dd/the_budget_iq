import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/models/date_range.dart';
import 'package:the_budget_iq/widgets/history/date_range_dropdown.dart';
import 'package:the_budget_iq/widgets/history/monthly_bar_chart.dart';
import 'package:the_budget_iq/widgets/home/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  DateRangeOption _selectedRange = DateRangeOption.thisMonth;

  // 🔄 CHANGED — Replaced `_selectedMonth` with a generic `_selectedBarIndex`
  // since selection now works for ALL ranges (not just monthly).
  // -1 means "no bar selected → show full range".
  int _selectedBarIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  // 📅 Format the subtitle based on the selected bar's bucket type
  String _selectedBarLabel(ChartBar bar) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];

    switch (_selectedRange.bucketType) {
      case BarBucket.day:
        return days[bar.start.weekday - 1];
      case BarBucket.week:
        return bar.label.replaceAll('W', 'Week ');
      case BarBucket.month:
        return '${months[bar.start.month - 1]} ${bar.start.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseStore>().expenses;
    final now = DateTime.now();

    // Build the bars for the active range, then fill in totals
    final rawBars = _selectedRange.buildBars(now);
    final bars = rawBars.map((b) {
      final total = expenses
          .where((e) =>
      !e.date.isBefore(b.start) && e.date.isBefore(b.end))
          .fold<double>(0, (sum, e) => sum + e.amount);
      return ChartBar(
        start: b.start,
        end: b.end,
        label: b.label,
        total: total,
      );
    }).toList();

    // 🔄 CHANGED — Filter window logic.
    // If a bar is selected, use ITS date range. Otherwise, use the full range.
    final ({DateTime start, DateTime end}) window;
    if (_selectedBarIndex >= 0 && _selectedBarIndex < bars.length) {
      final selected = bars[_selectedBarIndex];
      window = (start: selected.start, end: selected.end);
    } else {
      window = _selectedRange.range(now);
    }

    final filteredExpenses = expenses
        .where((e) =>
    !e.date.isBefore(window.start) && e.date.isBefore(window.end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final filteredTotal =
    filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    // 🆕 Convenience: is a bar currently selected?
    final hasSelection = _selectedBarIndex >= 0;

    // 🆕 Subtitle text that adapts to the selection
    final subtitle = hasSelection
        ? _selectedBarLabel(bars[_selectedBarIndex])
        : _selectedRange.label;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: DateRangeDropdown(
                selected: _selectedRange,
                onSelected: (r) {
                  setState(() {
                    _selectedRange = r;
                    // 🆕 Reset selection when range changes
                    _selectedBarIndex = -1;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'GH₵${filteredTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 🔄 CHANGED — All bars now tappable on every range.
                    MonthlyBarChart(
                      bars: bars,
                      selectedIndex: _selectedBarIndex,
                      onBarTapped: (i) {
                        setState(() {
                          // 🆕 Tap same bar again → deselect
                          // Tap different bar → switch selection
                          if (_selectedBarIndex == i) {
                            _selectedBarIndex = -1;
                          } else {
                            _selectedBarIndex = i;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // 🆕 NEW — Smart hint text:
                    // Shows "Tap bar again to clear" when a bar is selected,
                    // otherwise shows the long-press tip.
                    Text(
                      hasSelection
                          ? 'Tap the bar again to clear filter'
                          : 'Tip: long-press a transaction to edit or delete',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasSelection
                            ? const Color(0xFF6366F1)
                            : Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                        fontWeight: hasSelection
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filteredExpenses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      hasSelection
                          ? 'No transactions in $subtitle.'
                          : 'No transactions in ${_selectedRange.label.toLowerCase()}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final e = filteredExpenses[index];
                      return TransactionTile(expense: e);
                    },
                    childCount: filteredExpenses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
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

  // CHANGED: When the range is "This month" or another monthly range
  // and bars are tappable, this tracks which bar (= which month) the
  // user has selected. For non-tappable ranges, this is unused.
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  String _formatMonthYear(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseStore>().expenses;
    final now = DateTime.now();

    // CHANGED: Build the bars for the active range, then fill in totals
    // by walking the user's expenses and bucketing them.
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

    // CHANGED: For tappable ranges (months), figure out which bar is
    // currently "selected" so we can highlight it. For "This month",
    // use the user-picked month. For "Last 6 months" / "Last year",
    // default to the current month.
    int selectedBarIndex = -1;
    if (_selectedRange.barsAreTappable) {
      selectedBarIndex = bars.indexWhere((b) =>
      b.start.year == _selectedMonth.year &&
          b.start.month == _selectedMonth.month);
    }

    // CHANGED: The filter window depends on the range and (for monthly
    // ranges) on the selected bar.
    final ({DateTime start, DateTime end}) window;
    if (_selectedRange.barsAreTappable && selectedBarIndex >= 0) {
      // Show only the selected month's transactions.
      final selected = bars[selectedBarIndex];
      window = (start: selected.start, end: selected.end);
    } else {
      // Use the entire range (for week/day views).
      window = _selectedRange.range(now);
    }

    final filteredExpenses = expenses
        .where((e) => !e.date.isBefore(window.start) && e.date.isBefore(window.end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final filteredTotal =
    filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);

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
                    if (r.barsAreTappable) {
                      // Reset to the current month when switching into
                      // a tappable range.
                      _selectedMonth = DateTime(now.year, now.month);
                    }
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
                            // CHANGED: Subtitle reflects what we're actually showing.
                            // For tappable ranges, show the selected month.
                            // For others, show the range label.
                            _selectedRange.barsAreTappable
                                ? _formatMonthYear(_selectedMonth)
                                : _selectedRange.label,
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
                    // CHANGED: Chart now always renders, but adapts to the
                    // bar bucket type (day, week, or month).
                    MonthlyBarChart(
                      bars: bars,
                      selectedIndex: selectedBarIndex,
                      // CHANGED: Bars are tappable only for monthly ranges.
                      onBarTapped: _selectedRange.barsAreTappable
                          ? (i) {
                        setState(() {
                          _selectedMonth = bars[i].start;
                        });
                      }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tip: long-press a transaction to edit or delete',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
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
                      _selectedRange.barsAreTappable
                          ? 'No transactions in ${_formatMonthYear(_selectedMonth)}.'
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/widgets/history/monthly_bar_chart.dart';
// CHANGED: Reuse the existing TransactionTile (which already has long-press
// → bottom sheet → Edit/Delete). Removed the unused AddExpenseScreen and
// Expense imports because we no longer handle edit/delete inline here.
import 'package:the_budget_iq/widgets/home/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
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
    final List<DateTime> last12Months = List.generate(12, (i) {
      final m = DateTime(now.year, now.month - (11 - i));
      return DateTime(m.year, m.month);
    });

    final Map<DateTime, double> monthlyTotals = {
      for (final m in last12Months) m: 0,
    };

    for (final e in expenses) {
      final key = DateTime(e.date.year, e.date.month);
      if (monthlyTotals.containsKey(key)) {
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + e.amount;
      }
    }

    final monthExpenses = expenses
        .where((e) =>
    e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final selectedMonthTotal = monthlyTotals[_selectedMonth] ?? 0;

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
          'Transaction History',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
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
                          'GH₵${selectedMonthTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            _formatMonthYear(_selectedMonth),
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
                    MonthlyBarChart(
                      months: last12Months,
                      totals: monthlyTotals,
                      selectedMonth: _selectedMonth,
                      onMonthSelected: (m) =>
                          setState(() => _selectedMonth = m),
                    ),
                    // CHANGED: Subtle hint so users know long-press works here too.
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
            if (monthExpenses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No transactions in ${_formatMonthYear(_selectedMonth)}.',
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
                      final e = monthExpenses[index];
                      // CHANGED: Reuse TransactionTile so long-press behavior
                      // is identical to the home screen — same bottom sheet,
                      // same Edit/Delete options. No more inline icons.
                      return TransactionTile(expense: e);
                    },
                    childCount: monthExpenses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
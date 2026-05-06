import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/screens/transaction_history_screen.dart';
import 'package:the_budget_iq/widgets/home/budget_card.dart';
import 'package:the_budget_iq/widgets/home/home_header.dart';
import 'package:the_budget_iq/widgets/home/summary_card.dart';
import 'package:the_budget_iq/widgets/home/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseStore>();
    final expenses = store.expenses;
    final today = DateTime.now();

    final todayTotal = expenses
        .where((e) =>
    e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final monthTotal = expenses
        .where((e) =>
    e.date.year == today.year && e.date.month == today.month)
        .fold<double>(0, (sum, e) => sum + e.amount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 24),
            BudgetCard(
              spent: monthTotal,
              total: store.monthlyBudget,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(label: 'TODAY', amount: todayTotal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(label: 'MONTH', amount: monthTotal),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                // Tap "See All" → navigate to full transaction history
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (expenses.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'No transactions yet. Tap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              )
            else
              ...expenses
                  .take(10)
                  .map((e) => TransactionTile(expense: e)),
          ],
        ),
      ),
    );
  }
}
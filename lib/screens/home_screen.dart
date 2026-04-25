import 'package:flutter/material.dart';
import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/widgets/home/home_header.dart';
import 'package:the_budget_iq/widgets/home/budget_card.dart';
import 'package:the_budget_iq/widgets/home/summary_card.dart';
import 'package:the_budget_iq/widgets/home/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ExpenseStore.instance;
    final expenses = store.expenses;
    final monthlyBudget = store.monthlyBudget;

    final today = DateTime.now();

    final todayTotal = expenses
        .where((e) =>
    e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day)
        .fold(0.0, (sum, e) => sum + e.amount);

    final monthTotal = expenses
        .where((e) =>
    e.date.year == today.year && e.date.month == today.month)
        .fold(0.0, (sum, e) => sum + e.amount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 24),
            BudgetCard(spent: monthTotal, total: monthlyBudget),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: SummaryCard(label: 'TODAY', amount: todayTotal)),
                const SizedBox(width: 12),
                Expanded(child: SummaryCard(label: 'MONTH', amount: monthTotal)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All',
                      style: TextStyle(color: Color(0xFF6366F1))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No transactions yet. Tap + to add one.',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...expenses.take(5).map((e) => TransactionTile(expense: e)),
          ],
        ),
      ),
    );
  }
}
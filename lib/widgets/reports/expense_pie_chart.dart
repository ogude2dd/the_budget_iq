import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/expense.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;

  const ExpensePieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final total =
    categoryTotals.values.fold<double>(0, (sum, v) => sum + v);

    if (total == 0) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No expenses yet',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 70,
          sections: categoryTotals.entries
              .where((e) => e.value > 0)
              .map(
                (e) => PieChartSectionData(
              value: e.value,
              color: e.key.color,
              radius: 30,
              showTitle: false,
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
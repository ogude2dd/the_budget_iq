import 'package:flutter/material.dart';

import '../../models/expense.dart';

class CategoryLegend extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;

  const CategoryLegend({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final total =
    categoryTotals.values.fold<double>(0, (sum, v) => sum + v);

    final entries = categoryTotals.entries.where((e) => e.value > 0).toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: entries.map((e) {
        final percent = (e.value / total) * 100;
        return Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: e.key.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              e.key.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
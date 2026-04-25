import 'package:flutter/material.dart';

import '../../models/expense.dart';

class CategorySelector extends StatelessWidget {
  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onSelected;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ExpenseCategory.values.map((cat) {
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => onSelected(cat),
              child: Container(
                width: (MediaQuery.of(context).size.width - 32 - 12) / 2,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEEF2FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cat.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

enum ExpenseCategory { food, transport, entertainment, shopping, bills, other }

extension ExpenseCategoryExtension on ExpenseCategory {
  String get name {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFEF4444);
      case ExpenseCategory.transport:
        return const Color(0xFF3B82F6);
      case ExpenseCategory.entertainment:
        return const Color(0xFFF59E0B);
      case ExpenseCategory.shopping:
        return const Color(0xFF10B981);
      case ExpenseCategory.bills:
        return const Color(0xFF8B5CF6);
      case ExpenseCategory.other:
        return const Color(0xFF6B7280);
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.food:
        return '🥘';
      case ExpenseCategory.transport:
        return '🚗';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.bills:
        return '💡';
      case ExpenseCategory.other:
        return '📦';
    }
  }
}

class Expense {
  final String id;
  final double amount;
  final String description;
  final ExpenseCategory category;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });
}
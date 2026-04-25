import 'package:flutter/material.dart';

import 'models/expense.dart';
import 'widgets/main_scaffold.dart';

void main() {
  runApp(const TheBudgetIQApp());
}

// simple in-memory store (no database)
class ExpenseStore extends ChangeNotifier {
  ExpenseStore._();
  static final ExpenseStore instance = ExpenseStore._();

  final List<Expense> _expenses = [
    Expense(
      id: '1',
      amount: 20,
      description: 'Uber Ride',
      category: ExpenseCategory.transport,
      date: DateTime.now(),
    ),
  ];

  double _monthlyBudget = 2500;

  List<Expense> get expenses => List.unmodifiable(_expenses.reversed);

  double get monthlyBudget => _monthlyBudget;

  void addExpense(Expense e) {
    _expenses.add(e);
    notifyListeners();
  }

  void setMonthlyBudget(double amount) {
    _monthlyBudget = amount;
    notifyListeners();
  }
}

class TheBudgetIQApp extends StatelessWidget {
  const TheBudgetIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Budget IQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF6366F1),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: AnimatedBuilder(
        animation: ExpenseStore.instance,
        builder: (context, _) => const MainScaffold(),
      ),
    );
  }
}
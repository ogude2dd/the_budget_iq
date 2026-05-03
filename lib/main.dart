import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'models/expense.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseStore(),
      child: const TheBudgetIQApp(),
    ),
  );
}

class ExpenseStore extends ChangeNotifier {
  final List<Expense> _expenses = [];

  double _monthlyBudget = 0;

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
      home: const LoginScreen(),
    );
  }
}
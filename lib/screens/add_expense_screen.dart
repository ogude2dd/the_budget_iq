import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/expense.dart';
import '../widgets/add_expense/action_buttons.dart';
import '../widgets/add_expense/amount_field.dart';
import '../widgets/add_expense/category_selector.dart';
import '../widgets/add_expense/description_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  ExpenseCategory selectedCategory = ExpenseCategory.food;

  void _saveExpense() {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // ← CHANGED: use Provider instead of singleton
    context.read<ExpenseStore>().addExpense(
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        description: descriptionController.text.trim(),
        category: selectedCategory,
        date: DateTime.now(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Expense',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmountField(controller: amountController),
                      const SizedBox(height: 24),
                      DescriptionField(controller: descriptionController),
                      const SizedBox(height: 24),
                      CategorySelector(
                        selected: selectedCategory,
                        onSelected: (c) =>
                            setState(() => selectedCategory = c),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              ActionButtons(
                onCancel: () => Navigator.pop(context),
                onSave: _saveExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
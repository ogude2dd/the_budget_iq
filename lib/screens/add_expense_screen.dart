import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/models/expense.dart';
import 'package:the_budget_iq/utils/format.dart';
import 'package:the_budget_iq/widgets/add_expense/action_buttons.dart';
import 'package:the_budget_iq/widgets/add_expense/amount_field.dart';
import 'package:the_budget_iq/widgets/add_expense/category_selector.dart';
import 'package:the_budget_iq/widgets/add_expense/description_field.dart';

class AddExpenseScreen extends StatefulWidget {
  // 🆕 NEW PARAMETER — `existing`
  // If `existing` is provided → screen is in EDIT mode (pre-fills fields)
  // If `existing` is null     → screen is in ADD mode (original behavior)
  final Expense? existing;

  // 🔄 CHANGED — constructor now accepts optional `existing`
  const AddExpenseScreen({super.key, this.existing});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  ExpenseCategory selectedCategory = ExpenseCategory.food;

  // 🆕 NEW HELPER — clean way to check if we are editing
  // Used in build() and _saveExpense() to keep the code readable
  bool get _isEditing => widget.existing != null;

  // 🆕 NEW METHOD — initState
  // Pre-fills all the form fields if we're editing an existing expense.
  // Runs once when the screen opens.
  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      amountController.text = formatCurrency(e.amount);
      descriptionController.text = e.description;
      selectedCategory = e.category;
    }
  }

  void _saveExpense() {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final store = context.read<ExpenseStore>();

    // 🔄 CHANGED — branch between EDIT and ADD
    // If editing → call updateExpense (keeps the original ID and date)
    // If adding  → call addExpense (creates a new ID and uses today's date)
    if (_isEditing) {
      store.updateExpense(
        Expense(
          id: widget.existing!.id, // keep the original ID
          amount: amount,
          description: descriptionController.text.trim(),
          category: selectedCategory,
          date: widget.existing!.date, // keep the original date
        ),
      );
    } else {
      store.addExpense(
        Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          description: descriptionController.text.trim(),
          category: selectedCategory,
          date: DateTime.now(),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        // 🔄 CHANGED — title now reflects the mode (Edit vs Add)
        title: Text(
          _isEditing ? 'Edit Expense' : 'Add Expense',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // BUTTONS STAY AT BOTTOM
            Padding(
              padding: const EdgeInsets.all(16),
              child: ActionButtons(
                onCancel: () => Navigator.pop(context),
                onSave: _saveExpense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
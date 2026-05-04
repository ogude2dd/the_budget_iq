import 'package:flutter/material.dart';
// 🆕 NEW IMPORT — needed to call ExpenseStore methods
import 'package:provider/provider.dart';

// 🆕 NEW IMPORT — gives access to ExpenseStore (for deleteExpense)
import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/models/expense.dart';
// 🆕 NEW IMPORT — to navigate to AddExpenseScreen in EDIT mode
import 'package:the_budget_iq/screens/add_expense_screen.dart';
import 'package:the_budget_iq/utils/format.dart';
class TransactionTile extends StatelessWidget {
  final Expense expense;

  const TransactionTile({super.key, required this.expense});

  // 🆕 NEW METHOD — _showOptions
  // Shows a bottom sheet with Edit and Delete options when the user long-presses.
  // Uses showModalBottomSheet because it is more thumb-friendly than a popup
  // and matches modern finance app conventions.
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Small drag handle at the top — visual cue for a draggable sheet
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ✏️ Edit option
            ListTile(
              leading:
              const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
              title: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(sheetCtx); // close the sheet first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // 👇 Pass the existing expense → opens screen in EDIT mode
                    builder: (_) => AddExpenseScreen(existing: expense),
                  ),
                );
              },
            ),

            // 🗑️ Delete option
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDelete(context); // ask before deleting
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 🆕 NEW METHOD — _confirmDelete
  // Shows a confirmation dialog before actually deleting the expense.
  // Deleting is destructive, so we always ask first to prevent mistakes.
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: Text(
          'This will permanently remove "${expense.description.isEmpty ? expense.category.name : expense.description}" from your history.',
        ),
        actions: [
          // Cancel — closes the dialog
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),

          // Delete — actually removes the expense
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              // 👇 Calls the deleteExpense method we added to ExpenseStore
              context.read<ExpenseStore>().deleteExpense(expense.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 CHANGED — wrapped the original Container inside a GestureDetector
    // so we can capture long-press anywhere on the tile.
    // behavior: opaque ensures the WHOLE row is tappable, not just the icon/text.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _showOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(expense.category.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description.isEmpty
                        ? expense.category.name
                        : expense.description,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.category.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-GH₵${formatCurrency(expense.amount)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
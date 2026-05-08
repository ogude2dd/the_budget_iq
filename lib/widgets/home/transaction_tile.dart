import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/models/expense.dart';
import 'package:the_budget_iq/screens/add_expense_screen.dart';
import 'package:the_budget_iq/utils/format.dart';

class TransactionTile extends StatelessWidget {
  final Expense expense;

  const TransactionTile({super.key, required this.expense});

  // 🆕 NEW HELPER — formats DateTime to "8 May", "25 Jan" etc.
  // Shown next to the category name on each tile.
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  // Shows a bottom sheet with Edit and Delete options on long-press.
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
            // Small drag handle at the top
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
              leading: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF6366F1),
              ),
              title: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
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
                _confirmDelete(context);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Confirmation dialog before deleting.
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: Text(
          'This will permanently remove "${expense.description.isEmpty ? expense.category.name : expense.description}" from your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
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
            // Emoji icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                expense.category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),

            // Title + category + date
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

                  // 🔄 CHANGED — Added date next to the category name.
                  // Format: "Transport  ·  8 May"
                  Row(
                    children: [
                      Text(
                        expense.category.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        '  ·  ${_formatDate(expense.date)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
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
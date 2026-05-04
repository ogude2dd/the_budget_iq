import 'package:flutter/material.dart';
// CHANGED: Added Provider so we can access the ExpenseStore from context.
import 'package:provider/provider.dart';
// CHANGED: Import main.dart to access the ExpenseStore class defined there.
import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/screens/add_expense_screen.dart';
import 'package:the_budget_iq/screens/home_screen.dart';
import 'package:the_budget_iq/screens/reports_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    ReportsScreen(),
  ];

  // CHANGED: New initState method.
  // This runs once, the first time MainScaffold is shown.
  // We use it to load the signed-in user's data from Firestore so
  // that expenses and budget appear immediately after login or app reopen.
  @override
  void initState() {
    super.initState();
    // CHANGED: addPostFrameCallback runs the code AFTER the first frame
    // has been built. We need this because using `context.read` directly
    // inside initState (before any frame) can cause errors — Provider
    // isn't fully attached to this widget yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // CHANGED: Tells the ExpenseStore to fetch this user's expenses
      // and monthly budget from Firestore. The store will notify listeners
      // once the data arrives, which automatically updates the UI.
      context.read<ExpenseStore>().loadUserData();
    });
  }

  void _openAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _openAddExpense,
          icon: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_outlined, Icons.home, 'Home'),
              const SizedBox(width: 40), // gap for fab
              _navItem(1, Icons.pie_chart_outline, Icons.pie_chart, 'Reports'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData iconOutline, IconData iconFilled, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? iconFilled : iconOutline,
            color: selected ? const Color(0xFF6366F1) : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? const Color(0xFF6366F1) : Colors.grey.shade400,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
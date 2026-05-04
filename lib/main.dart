import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/expense.dart';
import 'screens/login_screen.dart';
import 'widgets/main_scaffold.dart';

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
  List<Expense> _expenses = [];
  double _monthlyBudget = 0;

  List<Expense> get expenses => List.unmodifiable(_expenses.reversed);
  double get monthlyBudget => _monthlyBudget;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _expensesRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('expenses');
  }

  DocumentReference<Map<String, dynamic>>? get _userRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(_userId);
  }

  // 📥 Load everything from Firestore after login
  Future<void> loadUserData() async {
    if (_userId == null) return;

    try {
      // Load monthly budget
      final userDoc = await _userRef!.get();
      if (userDoc.exists && userDoc.data()?['monthlyBudget'] != null) {
        _monthlyBudget = (userDoc.data()!['monthlyBudget'] as num).toDouble();
      }

      // Load expenses
      final snapshot = await _expensesRef!.orderBy('date').get();
      _expenses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Expense(
          id: doc.id,
          amount: (data['amount'] as num).toDouble(),
          description: data['description'] as String,
          category: ExpenseCategory.values[data['category'] as int],
          date: (data['date'] as Timestamp).toDate(),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // 💾 Save expense to Firestore
  Future<void> addExpense(Expense e) async {
    if (_expensesRef == null) return;

    try {
      await _expensesRef!.doc(e.id).set({
        'amount': e.amount,
        'description': e.description,
        'category': e.category.index,
        'date': Timestamp.fromDate(e.date),
      });

      _expenses.add(e);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving expense: $e');
    }
  }

  // 🆕 NEW METHOD ADDED — DELETE
  // 🗑️ Delete an expense from Firestore.
  // Removes the document from Firestore using its ID,
  // then removes it from the local _expenses list,
  // and finally notifies all listening widgets to rebuild.
  Future<void> deleteExpense(String id) async {
    if (_expensesRef == null) return;

    try {
      // Step 1: Remove from Firestore
      await _expensesRef!.doc(id).delete();

      // Step 2: Remove from local list to update UI instantly
      _expenses.removeWhere((e) => e.id == id);

      // Step 3: Tell Provider to rebuild widgets that watch this store
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
    }
  }

  // 🆕 NEW METHOD ADDED — UPDATE
  // ✏️ Update an existing expense in Firestore.
  // Uses set() with the same doc ID, which overwrites all fields
  // with the new values passed in.
  Future<void> updateExpense(Expense e) async {
    if (_expensesRef == null) return;

    try {
      // Step 1: Overwrite the existing Firestore document
      await _expensesRef!.doc(e.id).set({
        'amount': e.amount,
        'description': e.description,
        'category': e.category.index,
        'date': Timestamp.fromDate(e.date),
      });

      // Step 2: Replace the matching expense in the local list
      final idx = _expenses.indexWhere((x) => x.id == e.id);
      if (idx != -1) _expenses[idx] = e;

      // Step 3: Rebuild widgets that watch this store
      notifyListeners();
    } catch (err) {
      debugPrint('Error updating expense: $err');
    }
  }

  // 💰 Save budget to Firestore
  Future<void> setMonthlyBudget(double amount) async {
    if (_userRef == null) return;

    try {
      await _userRef!.set(
        {'monthlyBudget': amount},
        SetOptions(merge: true),
      );
      _monthlyBudget = amount;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving budget: $e');
    }
  }

  // 🚪 Clear when user logs out
  void clear() {
    _expenses = [];
    _monthlyBudget = 0;
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
      // ✅ Auto-route based on auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainScaffold();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
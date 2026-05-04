import 'package:flutter/material.dart';
// CHANGED: Firebase Auth — to sign the user out (and read their name).
import 'package:firebase_auth/firebase_auth.dart';
// CHANGED: Google Sign-In — needed to fully sign out users who logged
// in with Google. Firebase's signOut alone won't clear the cached
// Google account, so the next login would auto-pick the same account.
import 'package:google_sign_in/google_sign_in.dart';
// CHANGED: Provider — used to access the ExpenseStore from context.
import 'package:provider/provider.dart';
// CHANGED: main.dart contains ExpenseStore; login_screen.dart is where
// we navigate the user back to after logging out.
import 'package:the_budget_iq/main.dart';
import 'package:the_budget_iq/screens/login_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  // CHANGED: Logout method.
  // Made it a private method on the widget (rather than a top-level
  // function) so it lives next to the UI that calls it.
  Future<void> _logout(BuildContext context) async {
    // CHANGED: Show a confirmation dialog first. Without this, an
    // accidental tap on the avatar would log the user out instantly,
    // which would be frustrating. The dialog returns true if the user
    // confirms, false if they cancel.
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // CHANGED: Bail out if the user tapped Cancel or dismissed the dialog.
    if (shouldLogout != true) return;

    // CHANGED: Sign out of Google. Safe to call even for email-only users
    // (it's a no-op in that case). For Google users, this clears the
    // cached account so the next login shows the account picker again.
    await GoogleSignIn().signOut();

    // CHANGED: Sign out of Firebase. This is what actually ends the
    // authenticated session.
    await FirebaseAuth.instance.signOut();

    // CHANGED: `mounted` check before using context after async work.
    // If the widget was disposed mid-logout, we shouldn't touch context.
    if (!context.mounted) return;

    // CHANGED: Clear locally cached expenses and budget. Without this,
    // if another user logs in on the same device, they'd briefly see
    // the previous user's data before Firestore data loads in.
    context.read<ExpenseStore>().clear();

    // CHANGED: Navigate to LoginScreen and remove ALL previous routes
    // from the navigation stack. This way, the user can't press the
    // back button to sneak back into the logged-in app.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED: Read the currently signed-in user from Firebase so we
    // can greet them by name instead of always showing "Hello, User".
    // displayName is set during signup via updateDisplayName(name);
    // Google sign-in users get it from their Google account automatically.
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.split(' ').first // CHANGED: just the first name
        : 'there'; // CHANGED: friendly fallback if name isn't set

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHANGED: Greeting now uses the real user's first name.
              Text(
                'Hello, $displayName',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        // Existing notification bell — unchanged.
        Stack(
          children: [
            Icon(Icons.notifications_outlined,
                size: 28, color: Colors.grey.shade700),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // CHANGED: Wrapped the avatar in GestureDetector so tapping
        // it triggers the logout flow. Picked the avatar (rather than
        // adding a new icon) because "tap your profile to log out" is
        // a familiar pattern from apps like Gmail and Instagram.
        GestureDetector(
          onTap: () => _logout(context),
          child: Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Color(0xFF6B7280)),
              ),
              // CHANGED: Tiny purple logout indicator badge on the
              // bottom-right of the avatar. Without it, users wouldn't
              // know the avatar is tappable.
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
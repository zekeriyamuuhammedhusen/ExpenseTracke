import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool loading = false;

  Future<void> checkVerification() async {
    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser!;
    await user.reload(); // 🔥 REQUIRED
    final refreshedUser = FirebaseAuth.instance.currentUser;

    setState(() => loading = false);

    if (refreshedUser!.emailVerified) {
      // StreamBuilder in main.dart will auto-redirect
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email not verified yet")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Verify your email",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "A verification email was sent to:\n${user.email}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : checkVerification,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("I have verified"),
            ),

            TextButton(
              onPressed: () async {
                await user.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Verification email resent")),
                );
              },
              child: const Text("Resend email"),
            ),

            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text("Back to login"),
            ),
          ],
        ),
      ),
    );
  }
}

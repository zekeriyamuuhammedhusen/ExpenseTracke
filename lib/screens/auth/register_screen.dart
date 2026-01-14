import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final income = TextEditingController();
  bool loading = false;
  bool showPassword = false;

  Future<void> submit() async {
    setState(() => loading = true);

    final result = await AuthService.register(
      email: email.text.trim(),
      password: password.text.trim(),
      income: double.parse(income.text),
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Verification email sent. Please verify."),
      ),
    );
    Navigator.pop(context);
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade200, // background color for label
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 60, color: Colors.indigo),
            const SizedBox(height: 24),

            // EMAIL
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: inputDecoration("Email", Icons.email),
            ),
            const SizedBox(height: 16),

            // PASSWORD
            TextField(
              controller: password,
              obscureText: !showPassword,
              decoration: inputDecoration("Password", Icons.lock).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(showPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => showPassword = !showPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // INCOME
            TextField(
              controller: income,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Monthly Income", Icons.attach_money),
            ),
            const SizedBox(height: 24),

            // CREATE ACCOUNT BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                onPressed: loading ? null : submit,
                label: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

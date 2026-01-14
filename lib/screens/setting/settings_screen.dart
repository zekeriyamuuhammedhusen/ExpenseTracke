import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../account/update_account_screen.dart';
import '../../services/reauth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          Row(
            children: [
              const Icon(Icons.settings),
              Switch(
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ================= ACCOUNT =================
          const Text(
            "Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Update Account"),
            subtitle: const Text("Change email, password, or display name"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateAccountScreen()),
              );
            },
          ),
          const Divider(height: 40),

          // ================= SECURITY =================
          const Text(
            "Security",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Reset Password"),
            onTap: () async {
              if (user?.email != null) {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: user!.email!,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reset email sent")),
                );
              }
            },
          ),
          const Divider(height: 40),

          // ================= DELETE ACCOUNT =================
          const Text(
            "Danger Zone",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  /// 🔐 Re-authentication + delete
  void _showDeleteDialog(BuildContext context) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Re-authentication Required"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            filled: true,
            fillColor: Color(0xFFE0E0E0),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ReAuthService.deleteAccount(
                passwordController.text.trim(),
              );
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text(
              "DELETE",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
        ],
      ),
    );
  }
}

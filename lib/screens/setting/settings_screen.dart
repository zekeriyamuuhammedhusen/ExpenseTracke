import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/reauth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Change Password"),
            onTap: () => FirebaseAuth.instance.sendPasswordResetEmail(
              email: FirebaseAuth.instance.currentUser!.email!,
            ),
          ),
          ListTile(
            title: const Text("Delete Account"),
            textColor: Colors.red,
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Re-authentication Required"),
                content: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await ReAuthService.deleteAccount(
                        passwordController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("DELETE"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

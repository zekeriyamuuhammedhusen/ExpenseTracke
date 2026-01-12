import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delete Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "This action is permanent!",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: elevatedStyle(Colors.red),
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser!.delete();
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  child: const Text("Delete Account"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

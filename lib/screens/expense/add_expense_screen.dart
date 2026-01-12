import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/expense_manager.dart';
import '../../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String category = 'Food';
  bool loading = false;

  void saveExpense() async {
    final manager = Provider.of<ExpenseManager>(context, listen: false);

    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    if (manager.wallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wallet not initialized")),
      );
      return;
    }

    if (amount > manager.wallet!.remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient funds")),
      );
      return;
    }

    setState(() => loading = true);

    await manager.addExpense(
      Expense(
        id: '', // Firestore will generate ID
        title: titleController.text,
        amount: amount,
        category: category,
        date: DateTime.now(),
      ),
    );

    setState(() => loading = false);

    // Show warning if needed
    final warning = manager.getWarning();
    if (warning.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(warning)),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ExpenseManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              items: ['Food', 'Transport', 'Shopping', 'Other']
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveExpense,
                child: loading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text("Save Expense"),
              ),
            ),
            const SizedBox(height: 16),
            if (manager.wallet != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Income: ${manager.wallet!.total.toStringAsFixed(2)}"),
                  Text("Remaining: ${manager.wallet!.remaining.toStringAsFixed(2)}"),
                  Text(
                    manager.getWarning(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

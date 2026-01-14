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
  final descriptionController = TextEditingController();

  String category = 'Food';
  bool loading = false;

  /// Input decoration with background color
  InputDecoration _inputDecoration(
      BuildContext context,
      String label,
      String hint,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.indigo.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void saveExpense() async {
    final manager = Provider.of<ExpenseManager>(context, listen: false);

    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
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
        id: '', // Firestore auto-generates ID
        title: titleController.text,
        amount: amount,
        category: category,
        description: descriptionController.text,
        date: DateTime.now(),
      ),
    );

    setState(() => loading = false);

    final warning = manager.getWarning();
    if (warning.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(warning)),
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ExpenseManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Title
            TextField(
              controller: titleController,
              decoration: _inputDecoration(
                context,
                "Title",
                "e.g. Lunch, Taxi",
              ),
            ),
            const SizedBox(height: 16),

            /// Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                context,
                "Amount",
                "Enter expense amount",
              ),
            ),
            const SizedBox(height: 16),

            /// Description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: _inputDecoration(
                context,
                "Description (optional)",
                "Additional notes about this expense",
              ),
            ),
            const SizedBox(height: 16),

            /// Category
            DropdownButtonFormField<String>(
              value: category,
              decoration: _inputDecoration(context, "Category", ""),
              items: ['Food', 'Transport', 'Shopping', 'Other']
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 24),

            /// Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Save Expense",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Wallet info
            if (manager.wallet != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Income: ${manager.wallet!.total.toStringAsFixed(2)}",
                  ),
                  Text(
                    "Remaining: ${manager.wallet!.remaining.toStringAsFixed(2)}",
                  ),
                  if (manager.getWarning().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        manager.getWarning(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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

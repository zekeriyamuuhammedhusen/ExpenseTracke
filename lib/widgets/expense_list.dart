import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:provider/provider.dart';
import '../manager/expense_manager.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text("No expenses"));
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (_, i) {
        final e = expenses[i];
        return Card(
          child: ListTile(
            title: Text(e.title),
            subtitle: Text("${e.category} • ${e.amount}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<ExpenseManager>(context, listen: false)
                    .deleteExpense(e.id);
              },
            ),
          ),
        );
      },
    );
  }
}

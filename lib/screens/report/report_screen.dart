import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../../manager/expense_manager.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Future<void> exportToExcel(
      BuildContext context,
      ExpenseManager manager,
      ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Expenses'];

    // HEADER
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
      TextCellValue('Description'),
    ]);

    // DATA
    for (var e in manager.expenses) {
      sheet.appendRow([
        TextCellValue(e.date.toString()),
        TextCellValue(e.category),
        DoubleCellValue(e.amount),
        TextCellValue(e.description ?? ''),
      ]);
    }

    // SAVE FILE
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expense_report.xlsx');

    file
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Excel exported successfully!\n${file.path}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ExpenseManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Expense Report',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Text(
              'Total Expenses: ${manager.expenses.length}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export to Excel'),
                onPressed: manager.expenses.isEmpty
                    ? null
                    : () => exportToExcel(context, manager),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'The file will be saved in your app documents folder.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

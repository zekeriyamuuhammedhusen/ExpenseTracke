import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docs_gee/docs_gee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../manager/expense_manager.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _loading = false;

  Future<void> exportToWord(ExpenseManager manager) async {
    if (manager.expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Create a new Word document
      final doc = DocxDocument(
        title: 'Expense Report',
        author: 'Expense Tracker',
      );

      // Add a heading (H1)
      doc.addParagraph(DocxParagraph.heading('Expense Report', level: 1));

      // Add generated date
      doc.addParagraph(DocxParagraph.text(
          'Generated on ${DateTime.now().toLocal().toString().split(' ')[0]}'));

      // Spacer
      doc.addParagraph(DocxParagraph.text(' '));

      // Build table header & data rows
      List<List<String>> rows = [
        ['Date', 'Category', 'Amount', 'Description'],
        ...manager.expenses.map((e) => [
          e.date.toIso8601String().split('T')[0],
          e.category,
          e.amount.toString(),
          e.description ?? '',
        ])
      ];

      // Convert to docs_gee table
      final tableRows = rows.map((row) {
        return DocxTableRow(
          cells: row.map((cell) => DocxTableCell.text(cell)).toList(),
        );
      }).toList();

      doc.addTable(DocxTable(rows: tableRows));

      // Save file to app documents directory
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.docx';
      final file = File(filePath);

      final bytes = DocxGenerator().generate(doc);
      await file.writeAsBytes(bytes);

      // Open the file automatically
      await OpenFile.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Word file saved & opened:\n$filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate Word file: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ExpenseManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses: ${manager.expenses.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.download),
                label: Text(
                  _loading ? 'Generating...' : 'Export & Open Word Document',
                ),
                onPressed: _loading ? null : () => exportToWord(manager),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

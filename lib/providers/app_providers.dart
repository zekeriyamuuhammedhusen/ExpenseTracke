import 'package:provider/provider.dart';
import '../manager/expense_manager.dart';

final appProviders = [
  ChangeNotifierProvider(create: (_) => ExpenseManager()),
];

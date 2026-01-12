import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../manager/expense_manager.dart';
import '../../widgets/expense_list.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/stripe_service.dart';
import '../ai/ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    final manager = Provider.of<ExpenseManager>(context, listen: false);
    manager.fetchWallet();
    manager.listenExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ExpenseManager>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Expense Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // 🌙 DARK MODE TOGGLE
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),

          // 📊 REPORT
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.report),
          ),

          // 🚪 LOGOUT
          IconButton(
            icon: _isLoggingOut
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout),
            onPressed: _isLoggingOut
                ? null
                : () async {
              setState(() => _isLoggingOut = true);

              try {
                await AuthService.logout();
                if (!mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (_) => false);
              } finally {
                if (mounted) {
                  setState(() => _isLoggingOut = false);
                }
              }
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await manager.fetchWallet();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ================= WALLET CARD =================
              if (manager.wallet != null)
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Wallet Overview",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Income",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              manager.wallet!.total.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Remaining",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              manager.wallet!.remaining.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          manager.getWarning(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ================= RECENT EXPENSES =================
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Expenses",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: manager.expenses.isEmpty
                    ? const Center(
                  child: Text(
                    "No expenses yet.\nTap + to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: ExpenseList(expenses: manager.expenses),
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= FLOATING ACTION AREA =================
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 💳 STRIPE
                FloatingActionButton.extended(
                  heroTag: "stripe",
                  icon: const Icon(Icons.payment),
                  label: const Text("Pay"),
                  onPressed: () {
                    StripeService.pay(
                      context: context,
                      amount: 200,
                    );
                  },
                ),

                // 🤖 AI
                FloatingActionButton.extended(
                  heroTag: "ai",
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("AI Assistant"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiChatScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ➕ ADD EXPENSE
          FloatingActionButton(
            heroTag: "add",
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addExpense),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

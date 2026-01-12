import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'theme/theme_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/setting/settings_screen.dart';
import 'screens/expense/add_expense_screen.dart';
import 'screens/report/report_screen.dart';

import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ STRIPE INITIALIZATION (COMPLETE)
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripeKey == null || stripeKey.isEmpty) {
    debugPrint("⚠️ Stripe key not found in .env");
  } else {
    Stripe.publishableKey = stripeKey;
    await Stripe.instance.applySettings();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...appProviders,
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // 🌙 THEME
            themeMode: theme.mode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,
            ),

            // 📍 ROUTES
            routes: {
              AppRoutes.addExpense: (_) => const AddExpenseScreen(),
              AppRoutes.report: (_) => const ReportScreen(),
              AppRoutes.settings: (_) => const SettingsScreen(),
            },

            // 🔐 AUTH STATE HANDLER (CORRECT & SAFE)
            home: AuthGate(),
          );
        },
      ),
    );
  }
}

/// 🔐 AUTH GATE (BEST PRACTICE)
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ NOT LOGGED IN
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        // 📧 EMAIL NOT VERIFIED
        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        // ✅ LOGGED IN
        return const HomeScreen();
      },
    );
  }
}

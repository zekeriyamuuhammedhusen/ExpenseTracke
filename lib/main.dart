import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'theme/theme_provider.dart';

import 'screens/auth/welcome_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/expense/add_expense_screen.dart';
import 'screens/report/report_screen.dart';
import 'screens/setting/settings_screen.dart';

import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Stripe
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  try {
    if (stripeKey != null && stripeKey.isNotEmpty) {
      Stripe.publishableKey = stripeKey;
      await Stripe.instance.applySettings();
      debugPrint("✅ Stripe initialized");
    } else {
      debugPrint("⚠️ Stripe key not found in .env");
    }
  } catch (e) {
    debugPrint("❌ Stripe initialization failed: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}); // removed const

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
            themeMode: theme.themeMode,
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
            routes: {
              AppRoutes.addExpense: (_) => AddExpenseScreen(),
              AppRoutes.report: (_) => ReportScreen(),
              AppRoutes.settings: (_) => SettingsScreen(),
            },
            home: AuthGate(), // removed const
          );
        },
      ),
    );
  }
}

/// 🔐 AuthGate: directs users based on authentication & email verification
class AuthGate extends StatelessWidget {
  AuthGate({super.key}); // removed const

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in → Welcome Screen
        if (!snapshot.hasData) return WelcomeScreen();

        final user = snapshot.data!;

        // ⚠ Email not verified → VerifyEmailScreen
        if (!user.emailVerified) return VerifyEmailScreen();

        // ✅ Logged in → HomeScreen
        return HomeScreen();
      },
    );
  }
}

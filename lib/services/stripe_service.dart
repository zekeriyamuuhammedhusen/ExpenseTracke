import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StripeService {
  /// Start a Stripe payment
  /// [amount] in cents (1000 = $10)
  /// [currency] default "usd"
  static Future<void> pay({
    required BuildContext context,
    required int amount,
    String currency = 'usd',
  }) async {
    try {
      final url = dotenv.env['STRIPE_PAYMENT_URL'];

      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment service not configured')),
        );
        return;
      }

      // 1️⃣ Create PaymentIntent from backend
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize payment')),
        );
        return;
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      if (clientSecret == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid payment configuration')),
        );
        return;
      }

      // 2️⃣ Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Expense Tracker',
        ),
      );

      // 3️⃣ Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4️⃣ Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully!')),
      );
    }

    /// ❌ User pressed X / canceled payment
    on StripeException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment canceled')),
      );
    }

    /// ❌ Any other error
    catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed')),
      );
    }
  }
}

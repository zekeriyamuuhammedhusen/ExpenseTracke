import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class StripeService {
  /// Call this function to start a payment
  /// [amount] in cents (1000 = $10)
  /// [currency] default "usd"
  static Future<void> pay({required BuildContext context, required int amount, String currency = 'usd'}) async {
    try {
      final url = dotenv.env['STRIPE_PAYMENT_URL']!;

      // 1️⃣ Call backend to create PaymentIntent
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'currency': currency}),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create payment: ${response.body}')),
        );
        return;
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];
      if (clientSecret == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PaymentIntent creation failed')),
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

      // 4️⃣ Payment success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully!')),
      );
    } catch (e) {
      // Payment failed or canceled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }
}

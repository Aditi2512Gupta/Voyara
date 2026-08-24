import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 70,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Trip Saved Successfully!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 12),

                const Text(
                  "Your trip has been saved successfully.\n"
                  "You can view and manage it anytime from My Trips.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 20),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Trip saved securely"),
                  ],
                ),

                const SizedBox(height: 40),

                FilledButton(
                  onPressed: () {
                    context.go('/trips');
                  },
                  child: const Text("View My Trips"),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: const Text("Back to Home"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PricingHeader extends StatelessWidget {
  const PricingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Center the title and ensure full width for responsive centering
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Unlock unlimited AI power!',
          textAlign: TextAlign.center, // Center the Text widget
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Upgrade to Pro for a faster, more powerful, and uninterrupted experience.',
          textAlign: TextAlign.center, // Center the Text widget
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
      ],
    );
  }
}
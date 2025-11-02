import 'package:flutter/material.dart';

class AccountStatus extends StatelessWidget {
  final bool isPro;
  final int currentTokens;

  const AccountStatus({
    super.key,
    required this.isPro,
    required this.currentTokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPro ? Colors.indigo.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPro ? Colors.indigo.shade200 : Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Plan:',
                style: TextStyle(
                  fontSize: 14,
                  color: isPro ? Colors.indigo : Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPro ? 'Jarvis Pro' : 'Free Tier',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPro ? Colors.indigo.shade800 : Colors.blue.shade700,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tokens:',
                style: TextStyle(
                  fontSize: 14,
                  color: isPro ? Colors.indigo : Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPro ? 'UNLIMITED' : '$currentTokens left',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPro ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
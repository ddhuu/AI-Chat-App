import 'package:flutter/material.dart';

class PricingCard extends StatelessWidget {
  final String title;
  final String tag;
  final String price;
  final String description;
  final List<String> features;
  final bool isFeatured;
  final String buttonText;
  final VoidCallback? onTap; // Nullable for disabled button state

  const PricingCard({
    super.key,
    required this.title,
    required this.tag,
    required this.price,
    required this.description,
    required this.features,
    required this.isFeatured,
    required this.buttonText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor = isFeatured ? Colors.blue.shade700 : Colors.black;
    Color cardColor = isFeatured ? Colors.blue.shade50 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured ? primaryColor : Colors.grey.shade300,
          width: isFeatured ? 3 : 1,
        ),
        // Add shadow for the featured card
        boxShadow: isFeatured
            ? [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag (e.g., 'Current', 'Recommended')
          if (isFeatured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          else
            const SizedBox(height: 24),

          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          // Price
          Text(
            price,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
          const Divider(height: 30),

          // Features List
          // Checks for 'UNLIMITED' to apply bold styling (must match PricingPage content)
          ...features.map(
                (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: isFeatured ? primaryColor : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: feature.contains('UNLIMITED') ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFeatured ? primaryColor : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16,
                  color: isFeatured ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
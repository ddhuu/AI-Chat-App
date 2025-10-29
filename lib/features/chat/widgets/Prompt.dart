import 'package:flutter/material.dart';

class PromptItem extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const PromptItem({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      decoration: BoxDecoration(
        border: Border.all(width: 0.8, color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          IconButton(
            onPressed: onTap ?? () {},
            icon: const Icon(Icons.arrow_forward, color: Colors.blue, size: 16),
          ),
        ],
      ),
    );
  }
}

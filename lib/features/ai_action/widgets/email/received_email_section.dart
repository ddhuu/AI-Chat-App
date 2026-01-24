import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/colors.dart';

class ReceivedEmailSection extends StatelessWidget {
  final TextEditingController controller;

  const ReceivedEmailSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'email.received_email'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 8,
          minLines: 5,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'email.received_email_placeholder'.tr(),
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

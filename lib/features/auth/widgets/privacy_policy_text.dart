import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

class PrivacyPolicyText extends StatelessWidget {
  const PrivacyPolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        children: [
          const TextSpan(text: AppStrings.agreeToTerms + ' '),
          TextSpan(
            text: AppStrings.termsOfService,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Navigate to Terms of Service
              },
          ),
          const TextSpan(text: ' ${AppStrings.and} '),
          TextSpan(
            text: AppStrings.privacyPolicy,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Navigate to Privacy Policy
              },
          ),
        ],
      ),
    );
  }
}

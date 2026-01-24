import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/colors.dart';
import '../../providers/email_style_provider.dart';

class EmailStyleSection extends StatefulWidget {
  const EmailStyleSection({super.key});

  @override
  State<EmailStyleSection> createState() => _EmailStyleSectionState();
}

class _EmailStyleSectionState extends State<EmailStyleSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailStyleProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'email.email_style'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 12),
                            _buildStyleOption(
                              'email.length'.tr(),
                              provider.length,
                              ['short', 'medium', 'long'],
                              [
                                'email.length_short'.tr(),
                                'email.length_medium'.tr(),
                                'email.length_long'.tr(),
                              ],
                              provider.setLength,
                            ),
                            const SizedBox(height: 16),
                            _buildStyleOption(
                              'email.formality'.tr(),
                              provider.formality,
                              ['casual', 'formal'],
                              [
                                'email.formality_casual'.tr(),
                                'email.formality_formal'.tr(),
                              ],
                              provider.setFormality,
                            ),
                            const SizedBox(height: 16),
                            _buildStyleOption(
                              'email.tone'.tr(),
                              provider.tone,
                              ['friendly', 'professional', 'enthusiastic'],
                              [
                                'email.tone_friendly'.tr(),
                                'email.tone_professional'.tr(),
                                'email.tone_enthusiastic'.tr(),
                              ],
                              provider.setTone,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyleOption(
    String label,
    String currentValue,
    List<String> values,
    List<String> labels,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(values.length, (index) {
            final value = values[index];
            final isSelected = currentValue == value;
            return InkWell(
              onTap: () => onChanged(value),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

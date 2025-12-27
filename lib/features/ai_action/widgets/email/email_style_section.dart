import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                      const Text(
                        'Phong cách email',
                        style: TextStyle(
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
                              'Độ dài',
                              provider.length,
                              ['short', 'medium', 'long'],
                              ['Ngắn', 'Trung bình', 'Dài'],
                              provider.setLength,
                            ),
                            const SizedBox(height: 16),
                            _buildStyleOption(
                              'Tính trang trọng',
                              provider.formality,
                              ['casual', 'formal'],
                              ['Thân mật', 'Trang trọng'],
                              provider.setFormality,
                            ),
                            const SizedBox(height: 16),
                            _buildStyleOption(
                              'Giọng điệu',
                              provider.tone,
                              ['friendly', 'professional', 'enthusiastic'],
                              ['Thân thiện', 'Chuyên nghiệp', 'Nhiệt tình'],
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

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: const Text(
          'Nâng cấp lên Pro',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            const Icon(
              Icons.rocket_launch,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nâng cấp lên Pro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Mở khóa toàn bộ tính năng và trải nghiệm AI tốt nhất',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Free Plan
            _buildPlanCard(
              title: 'Free',
              price: '0đ',
              period: '/tháng',
              features: [
                'Truy cập GPT-3.5',
                '20 tin nhắn/ngày',
                'Tạo 2 AI Bot',
                'Upload file tối đa 5MB',
                'Lưu trữ 30 ngày',
              ],
              isCurrentPlan: true,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Pro Plan
            _buildPlanCard(
              title: 'Pro',
              price: '199.000đ',
              period: '/tháng',
              features: [
                'Truy cập GPT-4, Claude, Gemini',
                'Không giới hạn tin nhắn',
                'Tạo không giới hạn AI Bot',
                'Upload file tối đa 100MB',
                'Lưu trữ vĩnh viễn',
                'Ưu tiên hỗ trợ',
                'API Access',
                'Custom branding',
              ],
              isRecommended: true,
              onTap: () {
                _showUpgradeDialog(context);
              },
            ),
            const SizedBox(height: 16),

            // Enterprise Plan
            _buildPlanCard(
              title: 'Enterprise',
              price: 'Liên hệ',
              period: '',
              features: [
                'Tất cả tính năng Pro',
                'Dedicated support',
                'Custom AI models',
                'On-premise deployment',
                'SLA guarantee',
                'Training & consulting',
              ],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng liên hệ: enterprise@jarvisai.com'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Features Comparison
            const Text(
              'So sánh tính năng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    bool isCurrentPlan = false,
    bool isRecommended = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isRecommended
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? AppColors.primary : AppColors.divider,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isRecommended
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isRecommended
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isRecommended
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                        if (period.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 4),
                            child: Text(
                              period,
                              style: TextStyle(
                                fontSize: 16,
                                color: isRecommended
                                    ? Colors.white.withOpacity(0.8)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Phổ biến',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Features
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: isRecommended
                                ? AppColors.primary
                                : AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                          ? AppColors.primary
                          : AppColors.surface,
                      foregroundColor: isRecommended
                          ? Colors.white
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isRecommended
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          AppColors.textHint.withOpacity(0.1),
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Gói hiện tại'
                          : (price == 'Liên hệ' ? 'Liên hệ' : 'Nâng cấp'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCurrentPlan
                            ? AppColors.textHint
                            : (isRecommended ? Colors.white : AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildComparisonRow('Tính năng', 'Free', 'Pro', 'Enterprise', isHeader: true),
          _buildComparisonRow('AI Models', 'GPT-3.5', 'Tất cả', 'Custom'),
          _buildComparisonRow('Tin nhắn/ngày', '20', '∞', '∞'),
          _buildComparisonRow('AI Bots', '2', '∞', '∞'),
          _buildComparisonRow('File size', '5MB', '100MB', 'Custom'),
          _buildComparisonRow('Lưu trữ', '30 ngày', 'Vĩnh viễn', 'Vĩnh viễn'),
          _buildComparisonRow('API Access', '✗', '✓', '✓'),
          _buildComparisonRow('Support', 'Email', 'Priority', 'Dedicated'),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String free,
    String pro,
    String enterprise, {
    bool isHeader = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withOpacity(0.5),
          ),
        ),
        color: isHeader ? AppColors.background : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              free,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              pro,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                color: isHeader ? AppColors.textPrimary : AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              enterprise,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch, color: AppColors.primary),
            SizedBox(width: 12),
            Text(
              'Nâng cấp lên Pro',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn phương thức thanh toán:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              icon: Icons.credit_card,
              title: 'Thẻ tín dụng/ghi nợ',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng đang phát triển'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              icon: Icons.account_balance_wallet,
              title: 'Ví điện tử (Momo, ZaloPay)',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng đang phát triển'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              icon: Icons.qr_code,
              title: 'Chuyển khoản ngân hàng',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng đang phát triển'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

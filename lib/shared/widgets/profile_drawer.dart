import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/colors.dart';
import '../../shared/providers/token_usage_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../features/auth/pages/auth_page.dart';
import 'language_dialog.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Profile Header
            _buildProfileHeader(context),

            const SizedBox(height: 24),

            // Usage Card
            _buildUsageCard(context),

            const SizedBox(height: 24),

            // Settings Section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSectionHeader('profile.general'.tr()),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'profile.chat_settings'.tr(),
                    onTap: () {
                      // TODO: Navigate to chat settings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.palette_outlined,
                    title: 'profile.home_mode'.tr(),
                    trailing: 'profile.simple_mode'.tr(),
                    onTap: () {
                      // TODO: Navigate to theme settings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'profile.color_mode'.tr(),
                    trailing: 'profile.system_mode'.tr(),
                    onTap: () {
                      // TODO: Navigate to dark mode settings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.volume_up_outlined,
                    title: 'profile.voice'.tr(),
                    trailing: 'Nova',
                    onTap: () {
                      // TODO: Navigate to voice settings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.language_outlined,
                    title: 'profile.language'.tr(),
                    trailing: context.locale == const Locale('vi')
                        ? 'profile.vietnamese'.tr()
                        : 'profile.english'.tr(),
                    onTap: () => showLanguageDialog(context),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('profile.other'.tr()),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'profile.invite_friends'.tr(),
                    onTap: () {
                      // TODO: Navigate to referral
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.apps_outlined,
                    title: 'profile.apps'.tr(),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.telegram,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.facebook,
                          size: 16,
                          color: Colors.blue.shade800,
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to apps
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'profile.memory'.tr(),
                    trailing: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to memory settings
                    },
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final tokenProvider = context.watch<TokenUsageProvider>();
    final user = tokenProvider.currentUser;

    return Column(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: Text(
              user.email.isNotEmpty ? user.email[0].toUpperCase() : 'H',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.email.isNotEmpty ? user.email.split('@')[0] : 'Hữu Đoàn Đức',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          user.email.isNotEmpty ? user.email : 'ddhuu.dev@gmail.com',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildUsageCard(BuildContext context) {
    final tokenProvider = context.watch<TokenUsageProvider>();
    final isPro = tokenProvider.currentUser.plan != 'free';
    final remainingTokens = tokenProvider.remainingTokens;
    final totalTokens = tokenProvider.totalTokens;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPro ? 'profile.pro_plan'.tr() : 'profile.free_plan'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'profile.upgrade'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'profile.queries'.tr(),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Row(
                children: [
                  Text(
                    isPro
                        ? 'profile.unlimited'.tr()
                        : '$remainingTokens/$totalTokens',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    dynamic trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              if (trailing is String)
                Text(
                  trailing,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                )
              else
                trailing,
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('auth.logout'.tr()),
            content: Text('auth.logout_confirm'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('auth.logout'.tr()),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        // Save navigator and messenger before async gap
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        final authProvider = context.read<AuthProvider>();

        // Close drawer first
        navigator.pop();

        // Show loading
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text('auth.logging_out'.tr()),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Call logout API
        final result = await authProvider.logout();

        // Clear loading snackbar
        messenger.clearSnackBars();

        if (result == 'success') {
          // Show success message
          messenger.showSnackBar(
            SnackBar(
              content: Text('auth.logout_success'.tr()),
              backgroundColor: AppColors.success,
              duration: Duration(milliseconds: 800),
            ),
          );

          // Navigate to auth page
          Future.delayed(const Duration(milliseconds: 500), () {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthPage()),
              (route) => false,
            );
          });
        } else {
          // Show error message
          messenger.showSnackBar(
            SnackBar(
              content: Text(result ?? 'Đăng xuất thất bại'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(Icons.logout_outlined, size: 22, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Text(
              'auth.logout'.tr(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

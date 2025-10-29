import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 16),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Menu Items
          _DrawerMenuItem(
            icon: Icons.home_outlined,
            title: AppStrings.home,
            onTap: () => Navigator.pop(context),
          ),
          _DrawerMenuItem(
            icon: Icons.chat_bubble_outline,
            title: AppStrings.chat,
            onTap: () {},
          ),
          _DrawerMenuItem(
            icon: Icons.smart_toy_outlined,
            title: AppStrings.bot,
            onTap: () {},
          ),
          _DrawerMenuItem(
            icon: Icons.library_books_outlined,
            title: AppStrings.knowledge,
            onTap: () {},
          ),
          _DrawerMenuItem(
            icon: Icons.explore_outlined,
            title: AppStrings.aiAction,
            onTap: () {},
          ),

          const Divider(height: 1, color: AppColors.divider),

          _DrawerMenuItem(
            icon: Icons.logout_outlined,
            title: AppStrings.logout,
            onTap: () {},
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

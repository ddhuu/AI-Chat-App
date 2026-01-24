import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/colors.dart';
import '../../features/bot/pages/assistant_list_page.dart';
import '../../features/chat/chat_page.dart';
import '../../features/ai_action/pages/ai_action_page.dart';
import '../../features/ai_agent/pages/ai_agent_page.dart';
import '../../features/knowledge/pages/knowledge_list_page.dart';

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
                    Text(
                      'common.app_name'.tr(),
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
            title: 'navigation.home'.tr(),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
                (route) => false,
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.chat_bubble_outline,
            title: 'navigation.chat'.tr(),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
                (route) => false,
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.smart_toy_outlined,
            title: 'navigation.bot'.tr(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssistantListPage(),
                ),
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.library_books_outlined,
            title: 'navigation.knowledge'.tr(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeListPage(),
                ),
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.explore_outlined,
            title: 'navigation.ai_action'.tr(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIActionPage()),
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.psychology_outlined,
            title: 'navigation.ai_agent'.tr(),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiAgentPage()),
              );
            },
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

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

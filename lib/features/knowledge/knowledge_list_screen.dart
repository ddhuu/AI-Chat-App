// lib/screens/knowledge/knowledge_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// !! Nhớ đổi 'your_app'
import '/core/constants/assets.dart';
import '/core/constants/colors.dart';

class KnowledgeListScreen extends StatelessWidget {
  const KnowledgeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final searchBar = TextField(
      decoration: InputDecoration(
        hintText: 'Search knowledge base...',
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.sidebarBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );

    final createButton = ElevatedButton.icon(
      onPressed: () {
        // TODO: Gọi context.go('/knowledge/create')
      },
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Create Knowledge'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: isMobile ? const Size(double.infinity, 56) : null,
      ),
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 48,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Text(
                'Knowledge Base',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (isMobile) ...[
              createButton,
              const SizedBox(height: 16),
              searchBar,
            ] else ...[
              Row(
                children: [
                  Expanded(child: searchBar),
                  const SizedBox(width: 16),
                  createButton,
                ],
              ),
            ],
            const SizedBox(height: 32),
            
            // Trạng thái rỗng (Đã "inline" theo yêu cầu của bạn)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.knowledgeEmpty,
                      height: 150,
                      placeholderBuilder: (context) => Container(
                        height: 150,
                        width: 150,
                        color: AppColors.border,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No knowledge found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                         // TODO: context.go('/knowledge/create')
                      },
                      child: const Text(
                        'Create your own knowledge',
                        style: TextStyle(color: AppColors.textLink, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
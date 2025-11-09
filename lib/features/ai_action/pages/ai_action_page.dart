import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/AppDrawer.dart';
import '../../email/pages/email_draft_page.dart';
import '../models/action_item.dart';
import '../widgets/action_card.dart';

class AIActionPage extends StatefulWidget {
  const AIActionPage({super.key});

  @override
  State<AIActionPage> createState() => _AIActionPageState();
}

class _AIActionPageState extends State<AIActionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ActionItem> _filteredActions = [];

  // List of available AI actions
  static const List<ActionItem> _allActions = [
    ActionItem(
      name: 'Email',
      description: 'Compose professional emails with AI assistance',
      icon: Icons.email_outlined,
      page: EmailDraftPage(),
    ),
    // Add more actions here in the future
    // ActionItem(
    //   name: 'Social Media',
    //   description: 'Generate engaging social media posts',
    //   icon: Icons.share_outlined,
    //   page: SocialMediaPage(),
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredActions = _allActions;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterActions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredActions = _allActions;
      } else {
        _filteredActions = _allActions.where((action) {
          return action.name.toLowerCase().contains(query.toLowerCase()) ||
              action.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          ),
          title: const Text(
            'AI Action',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        drawer: const SafeArea(child: AppDrawer()),
        body: Column(
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: _filterActions,
                decoration: InputDecoration(
                  hintText: 'Search AI actions...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Actions Grid
            Expanded(
              child: _filteredActions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No actions found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _filteredActions.length,
                      itemBuilder: (context, index) {
                        return ActionCard(action: _filteredActions[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

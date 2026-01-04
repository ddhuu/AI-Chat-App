import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/AppDrawer.dart';
import '../models/ai_agent_model.dart';
import '../providers/ai_agent_provider.dart';
import '../widgets/agent_card.dart';
import 'weather_agent_chat_page.dart';

class AiAgentPage extends StatefulWidget {
  const AiAgentPage({super.key});

  @override
  State<AiAgentPage> createState() => _AiAgentPageState();
}

class _AiAgentPageState extends State<AiAgentPage> {
  final TextEditingController _searchController = TextEditingController();
  List<AiAgent> _filteredAgents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AiAgentProvider>();
      setState(() {
        _filteredAgents = provider.agents;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAgents(String query) {
    final provider = context.read<AiAgentProvider>();
    setState(() {
      if (query.isEmpty) {
        _filteredAgents = provider.agents;
      } else {
        _filteredAgents = provider.agents.where((agent) {
          return agent.name.toLowerCase().contains(query.toLowerCase()) ||
              agent.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToAgent(AiAgent agent) {
    if (agent.type == AgentType.weather) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherAgentChatPage(agent: agent),
        ),
      );
    }
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
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: AppColors.textSecondary),
            ),
          ),
          title: const Text(
            'AI Agent',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Consumer<AiAgentProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (_filteredAgents.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildAgentList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterAgents,
        decoration: InputDecoration(
          hintText: 'Search agents...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade50,
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
    );
  }

  Widget _buildAgentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAgents.length,
      itemBuilder: (context, index) {
        final agent = _filteredAgents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AgentCard(agent: agent, onTap: () => _navigateToAgent(agent)),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No agents found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

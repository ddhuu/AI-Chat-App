import 'package:flutter/material.dart';
import '../models/ai_agent_model.dart';

class AiAgentProvider extends ChangeNotifier {
  List<AiAgent> _agents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AiAgent> get agents => _agents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AiAgentProvider() {
    _loadDefaultAgents();
  }

  void _loadDefaultAgents() {
    _agents = [
      AiAgent(
        id: 'weather-agent',
        name: 'Weather Agent',
        description: 'Get current weather information for any city',
        webhookUrl: 'https://huudd.app.n8n.cloud/webhook-test/weather-now',
        icon: '🌤️',
        type: AgentType.weather,
      ),
    ];
    notifyListeners();
  }

  AiAgent? getAgentById(String id) {
    try {
      return _agents.firstWhere((agent) => agent.id == id);
    } catch (e) {
      return null;
    }
  }

  void addAgent(AiAgent agent) {
    _agents.add(agent);
    notifyListeners();
  }

  void removeAgent(String id) {
    _agents.removeWhere((agent) => agent.id == id);
    notifyListeners();
  }

  void updateAgent(AiAgent agent) {
    final index = _agents.indexWhere((a) => a.id == agent.id);
    if (index != -1) {
      _agents[index] = agent;
      notifyListeners();
    }
  }
}

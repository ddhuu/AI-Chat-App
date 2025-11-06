class KnowledgeModel {
  final String id;
  final String name;
  final double size; // in MB

  KnowledgeModel({
    required this.id,
    required this.name,
    required this.size,
  });

  // Mock data for testing
  static List<KnowledgeModel> getMockKnowledge() {
    return [
      KnowledgeModel(
        id: '1',
        name: 'Flutter Documentation',
        size: 1.02,
      ),
      KnowledgeModel(
        id: '2',
        name: 'Dart Language Guide',
        size: 0.77,
      ),
      KnowledgeModel(
        id: '3',
        name: 'Deep Learning Basics',
        size: 5.79,
      ),
      KnowledgeModel(
        id: '4',
        name: 'Machine Learning Guide',
        size: 3.45,
      ),
      KnowledgeModel(
        id: '5',
        name: 'AI Best Practices',
        size: 2.18,
      ),
    ];
  }
}

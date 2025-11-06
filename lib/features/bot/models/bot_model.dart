// Mock Bot Model for UI display
class BotModel {
  final String id;
  final String name;
  final String description;
  final String createdDate;
  final List<String> knowledgeList;
  bool isFavorite;
  bool isPublished;

  BotModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.knowledgeList,
    this.isFavorite = false,
    this.isPublished = false,
  });

  // Mock data for testing UI
  static List<BotModel> getMockBots() {
    return [
      BotModel(
        id: '1',
        name: 'Code Assistant',
        description: 'Trợ lý lập trình thông minh, giúp viết code và debug',
        createdDate: '15/10/2024',
        knowledgeList: ['Flutter', 'Dart', 'Clean Code'],
        isFavorite: true,
        isPublished: true,
      ),
      BotModel(
        id: '2',
        name: 'Email Writer',
        description: 'Viết email chuyên nghiệp và hiệu quả',
        createdDate: '20/10/2024',
        knowledgeList: ['Business Writing', 'Email Templates'],
        isFavorite: false,
        isPublished: false,
      ),
      BotModel(
        id: '3',
        name: 'Content Creator',
        description: 'Tạo nội dung sáng tạo cho social media',
        createdDate: '25/10/2024',
        knowledgeList: ['Marketing', 'SEO', 'Copywriting'],
        isFavorite: true,
        isPublished: true,
      ),
      BotModel(
        id: '4',
        name: 'Study Buddy',
        description: 'Trợ lý học tập, giải thích kiến thức dễ hiểu',
        createdDate: '01/11/2024',
        knowledgeList: ['Education', 'Learning Methods'],
        isFavorite: false,
        isPublished: false,
      ),
      BotModel(
        id: '5',
        name: 'Translation Expert',
        description: 'Dịch thuật chính xác đa ngôn ngữ',
        createdDate: '03/11/2024',
        knowledgeList: ['Languages', 'Translation'],
        isFavorite: false,
        isPublished: true,
      ),
    ];
  }
}

/// Base class for Prompt
class PromptModel {
  final String id;
  final String name;
  final String content;
  bool isFavorite;

  PromptModel({
    required this.id,
    required this.name,
    required this.content,
    this.isFavorite = false,
  });

  /// Extract keywords from prompt content (text in square brackets [])
  List<String> extractKeywords() {
    final RegExp regExp = RegExp(r'\[([^\]]+)\]');
    final Iterable<RegExpMatch> matches = regExp.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// Replace keywords with user input
  String fillKeywords(Map<String, String> inputs) {
    String result = content;
    inputs.forEach((keyword, value) {
      result = result.replaceAll('[$keyword]', value);
    });
    return result;
  }
}

/// Private Prompt (user-created)
class PrivatePrompt extends PromptModel {
  PrivatePrompt({
    required super.id,
    required super.name,
    required super.content,
    super.isFavorite,
  });

  factory PrivatePrompt.fromJson(Map<String, dynamic> json) {
    return PrivatePrompt(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'isFavorite': isFavorite,
    };
  }
}

/// Public Prompt (community/template)
class PublicPrompt extends PromptModel {
  final String category;
  final String description;

  PublicPrompt({
    required super.id,
    required super.name,
    required super.content,
    required this.category,
    this.description = '',
    super.isFavorite,
  });

  factory PublicPrompt.fromJson(Map<String, dynamic> json) {
    return PublicPrompt(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'category': category,
      'description': description,
      'isFavorite': isFavorite,
    };
  }
}

/// Prompt categories
class PromptCategory {
  static const String all = 'All';
  static const String marketing = 'Marketing';
  static const String business = 'Business';
  static const String seo = 'SEO';
  static const String writing = 'Writing';
  static const String coding = 'Coding';
  static const String career = 'Career';
  static const String chatbot = 'Chatbot';
  static const String education = 'Education';
  static const String fun = 'Fun';
  static const String productivity = 'Productivity';
  static const String other = 'Other';

  static const List<String> allCategories = [
    all,
    marketing,
    business,
    seo,
    writing,
    coding,
    career,
    chatbot,
    education,
    fun,
    productivity,
    other,
  ];
}

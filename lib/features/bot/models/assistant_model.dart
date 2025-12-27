// AI Assistant (Bot) Model based on new API
class Assistant {
  final String id;
  final String assistantName;
  final String? openAiAssistantId;
  final String? instructions;
  final String? description;
  final String? openAiThreadIdPlay;
  final String? model;
  final String userId;
  final bool isDefault;
  final String? createdBy;
  final String? updatedBy;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic>? config;

  Assistant({
    required this.id,
    required this.assistantName,
    this.openAiAssistantId,
    this.instructions,
    this.description,
    this.openAiThreadIdPlay,
    this.model,
    required this.userId,
    this.isDefault = false,
    this.createdBy,
    this.updatedBy,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.config,
  });

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'] as String,
      assistantName: json['assistantName'] as String,
      openAiAssistantId: json['openAiAssistantId'] as String?,
      instructions: json['instructions'] as String?,
      description: json['description'] as String?,
      openAiThreadIdPlay: json['openAiThreadIdPlay'] as String?,
      model: json['model'] as String?,
      userId: json['userId'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assistantName': assistantName,
      'openAiAssistantId': openAiAssistantId,
      'instructions': instructions,
      'description': description,
      'openAiThreadIdPlay': openAiThreadIdPlay,
      'model': model,
      'userId': userId,
      'isDefault': isDefault,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'config': config,
    };
  }

  Assistant copyWith({
    String? id,
    String? assistantName,
    String? openAiAssistantId,
    String? instructions,
    String? description,
    String? openAiThreadIdPlay,
    String? model,
    String? userId,
    bool? isDefault,
    String? createdBy,
    String? updatedBy,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Map<String, dynamic>? config,
  }) {
    return Assistant(
      id: id ?? this.id,
      assistantName: assistantName ?? this.assistantName,
      openAiAssistantId: openAiAssistantId ?? this.openAiAssistantId,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      openAiThreadIdPlay: openAiThreadIdPlay ?? this.openAiThreadIdPlay,
      model: model ?? this.model,
      userId: userId ?? this.userId,
      isDefault: isDefault ?? this.isDefault,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      config: config ?? this.config,
    );
  }
}

// Response model for list assistants
class AssistantsResponse {
  final List<Assistant> data;
  final AssistantsMeta meta;

  AssistantsResponse({required this.data, required this.meta});

  factory AssistantsResponse.fromJson(Map<String, dynamic> json) {
    return AssistantsResponse(
      data: (json['data'] as List)
          .map((item) => Assistant.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: AssistantsMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class AssistantsMeta {
  final int limit;
  final int total;
  final int offset;
  final bool hasNext;

  AssistantsMeta({
    required this.limit,
    required this.total,
    required this.offset,
    required this.hasNext,
  });

  factory AssistantsMeta.fromJson(Map<String, dynamic> json) {
    return AssistantsMeta(
      limit: json['limit'] as int,
      total: json['total'] as int,
      offset: json['offset'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }
}

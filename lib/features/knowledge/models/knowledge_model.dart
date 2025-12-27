class Knowledge {
  final String id;
  final String knowledgeName;
  final String description;
  final String userId;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Knowledge({
    required this.id,
    required this.knowledgeName,
    required this.description,
    required this.userId,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Knowledge.fromJson(Map<String, dynamic> json) {
    return Knowledge(
      id: json['id'] as String,
      knowledgeName: json['knowledgeName'] as String,
      description: json['description'] as String? ?? '',
      userId: json['userId'] as String,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'knowledgeName': knowledgeName,
      'description': description,
      'userId': userId,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  Knowledge copyWith({
    String? id,
    String? knowledgeName,
    String? description,
    String? userId,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Knowledge(
      id: id ?? this.id,
      knowledgeName: knowledgeName ?? this.knowledgeName,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

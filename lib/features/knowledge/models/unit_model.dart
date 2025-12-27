class Unit {
  final String id;
  final String name;
  final String type;
  final int? size;
  final bool status;
  final String userId;
  final UnitMetadata metadata;
  final String knowledgeId;
  final String syncStatus;

  Unit({
    required this.id,
    required this.name,
    required this.type,
    this.size,
    required this.status,
    required this.userId,
    required this.metadata,
    required this.knowledgeId,
    required this.syncStatus,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: json['size'] as int?,
      status: json['status'] as bool,
      userId: json['userId'] as String,
      metadata: UnitMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      knowledgeId: json['knowledgeId'] as String,
      syncStatus: json['syncStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'size': size,
      'status': status,
      'userId': userId,
      'metadata': metadata.toJson(),
      'knowledgeId': knowledgeId,
      'syncStatus': syncStatus,
    };
  }
}

class UnitMetadata {
  final String? description;
  final String createdAt;
  final String updatedAt;
  final bool enabled;

  UnitMetadata({
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.enabled,
  });

  factory UnitMetadata.fromJson(Map<String, dynamic> json) {
    return UnitMetadata(
      description: json['description'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      enabled: json['enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'enabled': enabled,
    };
  }
}

class UnitsResponse {
  final String knowledgeId;
  final List<Unit> data;
  final UnitsMeta meta;

  UnitsResponse({
    required this.knowledgeId,
    required this.data,
    required this.meta,
  });

  factory UnitsResponse.fromJson(Map<String, dynamic> json) {
    return UnitsResponse(
      knowledgeId: json['knowledgeId'] as String,
      data: (json['data'] as List)
          .map((item) => Unit.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: UnitsMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class UnitsMeta {
  final int total;
  final int limit;
  final int offset;
  final bool hasNext;

  UnitsMeta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasNext,
  });

  factory UnitsMeta.fromJson(Map<String, dynamic> json) {
    return UnitsMeta(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }
}

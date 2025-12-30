// Email Style DTO
class EmailStyleDto {
  final String? length;
  final String? formality;
  final String? tone;

  EmailStyleDto({this.length, this.formality, this.tone});

  Map<String, dynamic> toJson() {
    return {
      if (length != null) 'length': length,
      if (formality != null) 'formality': formality,
      if (tone != null) 'tone': tone,
    };
  }
}

// Email Content (for context)
class EmailContent {
  final String role;
  final String content;

  EmailContent({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }

  factory EmailContent.fromJson(Map<String, dynamic> json) {
    return EmailContent(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

// AI Email Metadata
class AiEmailMetadata {
  final List<EmailContent> context;
  final String subject;
  final String sender;
  final String receiver;
  final EmailStyleDto style;
  final String? language;

  AiEmailMetadata({
    required this.context,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.style,
    this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'context': context.map((e) => e.toJson()).toList(),
      'subject': subject,
      'sender': sender,
      'receiver': receiver,
      'style': style.toJson(),
      if (language != null) 'language': language,
    };
  }
}

// AI Email Reply Ideas Metadata
class AiEmailReplyIdeasMetadata {
  final List<EmailContent> context;
  final String subject;
  final String sender;
  final String receiver;
  final String language;

  AiEmailReplyIdeasMetadata({
    required this.context,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'context': context.map((e) => e.toJson()).toList(),
      'subject': subject,
      'sender': sender,
      'receiver': receiver,
      'language': language,
    };
  }
}

// Assistant DTO (optional)
class AssistantDto {
  final String? id;

  AssistantDto({this.id});

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id};
  }
}

// Email Reply Request
class EmailReplyRequest {
  final String email;
  final String action;
  final String mainIdea;
  final AiEmailMetadata metadata;

  EmailReplyRequest({
    required this.email,
    this.action = 'Reply to this email',
    required this.mainIdea,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'action': action,
      'mainIdea': mainIdea,
      'metadata': metadata.toJson(),
    };
  }
}

// Email Suggest Ideas Request
class EmailSuggestIdeasRequest {
  final AssistantDto? assistant;
  final String? model;
  final String email;
  final String action;
  final AiEmailReplyIdeasMetadata metadata;

  EmailSuggestIdeasRequest({
    this.assistant,
    this.model,
    required this.email,
    required this.action,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      if (assistant != null) 'assistant': assistant!.toJson(),
      if (model != null) 'model': model,
      'email': email,
      'action': action,
      'metadata': metadata.toJson(),
    };
  }
}

// Email Reply Response
class EmailReplyResponse {
  final String email;
  final int? remainingUsage;
  final List<String>? improvedActions;

  EmailReplyResponse({
    required this.email,
    this.remainingUsage,
    this.improvedActions,
  });

  factory EmailReplyResponse.fromJson(Map<String, dynamic> json) {
    return EmailReplyResponse(
      email: json['email'] ?? '',
      remainingUsage: json['remainingUsage'],
      improvedActions: json['improvedActions'] != null
          ? List<String>.from(json['improvedActions'])
          : null,
    );
  }
}

// Suggest Ideas Response
class SuggestIdeasResponse {
  final List<String> ideas;

  SuggestIdeasResponse({required this.ideas});

  factory SuggestIdeasResponse.fromJson(Map<String, dynamic> json) {
    if (json['ideas'] != null && json['ideas'] is List) {
      return SuggestIdeasResponse(ideas: List<String>.from(json['ideas']));
    }
    return SuggestIdeasResponse(ideas: []);
  }
}

/// Email action types for AI-generated responses
enum EmailActionType {
  thanks,
  sorry,
  yes,
  no,
  followUp,
  requestInfo,
}

/// Extension to get display name and icon for each action type
extension EmailActionTypeExtension on EmailActionType {
  String get displayName {
    switch (this) {
      case EmailActionType.thanks:
        return 'Thanks';
      case EmailActionType.sorry:
        return 'Sorry';
      case EmailActionType.yes:
        return 'Yes';
      case EmailActionType.no:
        return 'No';
      case EmailActionType.followUp:
        return 'Follow up';
      case EmailActionType.requestInfo:
        return 'Request for more information';
    }
  }

  String get icon {
    switch (this) {
      case EmailActionType.thanks:
        return '🙏';
      case EmailActionType.sorry:
        return '😔';
      case EmailActionType.yes:
        return '👍';
      case EmailActionType.no:
        return '👎';
      case EmailActionType.followUp:
        return '📧';
      case EmailActionType.requestInfo:
        return '❓';
    }
  }

  String get description {
    switch (this) {
      case EmailActionType.thanks:
        return 'Generate a thank you email';
      case EmailActionType.sorry:
        return 'Generate an apology email';
      case EmailActionType.yes:
        return 'Generate a positive response';
      case EmailActionType.no:
        return 'Generate a polite decline';
      case EmailActionType.followUp:
        return 'Generate a follow-up email';
      case EmailActionType.requestInfo:
        return 'Request additional information';
    }
  }
}

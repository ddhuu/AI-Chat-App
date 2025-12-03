import 'package:event_bus/event_bus.dart';

// Global event bus instance
final EventBus eventBus = EventBus();

// Event when token refresh fails -> redirect to login
class TokenRefreshFailedEvent {}

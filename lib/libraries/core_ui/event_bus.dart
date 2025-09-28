import 'dart:async';

/// Global event bus for cross-BloC communication
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final StreamController<dynamic> _eventController = StreamController<dynamic>.broadcast();

  Stream<T> on<T>() => _eventController.stream.where((event) => event is T).cast<T>();

  void fire(dynamic event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

/// Events that can be fired across the app
class RecentlyViewedUpdatedEvent {
  final String projectId;
  RecentlyViewedUpdatedEvent(this.projectId);
}

class HomeScreenRefreshRequestedEvent {
  final String? projectId;
  HomeScreenRefreshRequestedEvent({this.projectId});
}

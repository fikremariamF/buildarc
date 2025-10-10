import 'dart:async';
import 'package:injectable/injectable.dart';

@singleton
class EventBus {

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

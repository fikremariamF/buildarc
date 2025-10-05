import 'package:ardennes/libraries/core_ui/event_bus.dart';
import 'package:ardennes/libraries/drawing/recently_viewed_drawing_provider.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'event.dart';
import 'state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final RecentlyViewedService recentlyViewedService;
  final EventBus _eventBus;
  StreamSubscription? _eventSubscription;
  ProjectMetadata? _currentProject;

  HomeScreenBloc({
    required this.recentlyViewedService,
    required EventBus eventBus,
  }) : _eventBus = eventBus,
       super(HomeScreenState().init()) {
    on<InitEvent>(_init);
    on<FetchHomeScreenContentEvent>(_fetchHomeScreenContent);
    on<ListenToEventsEvent>(_listenToEvents);
    
    startListeningGlobalEvenets();
  }

  void startListeningGlobalEvenets() {
    _eventSubscription = _eventBus.on<RecentlyViewedUpdatedEvent>().listen((event) {
      final currentProject = _currentProject;
      if (currentProject != null && event.projectId == currentProject.id) {
        add(FetchHomeScreenContentEvent(currentProject));
      }
    });
    
    _eventBus.on<HomeScreenRefreshRequestedEvent>().listen((event) {
      final currentProject = _currentProject;
      if (currentProject != null && (event.projectId == null || event.projectId == currentProject.id)) {
        add(FetchHomeScreenContentEvent(currentProject));
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }

  void _init(InitEvent event, Emitter<HomeScreenState> emit) async {
    emit(state.clone());
  }

  void _fetchHomeScreenContent(
    FetchHomeScreenContentEvent event, Emitter<HomeScreenState> emit) async {
  emit(FetchingHomeScreenContentState());
  
  _currentProject = event.selectedProject;
  
  try {
    final projectId = event.selectedProject.id;
    if (projectId == null) {
      debugPrint("ERROR: Project ID is required");
      emit(HomeScreenFetchErrorState("Project ID is required"));
      return;
    }
    
    final result = await recentlyViewedService.getRecentlyViewedDrawings(
      projectId: projectId,
    );
    
           if (result.isSuccess) {
             emit(FetchedHomeScreenContentState(recentlyViewedDrawingTiles: result.data!));
           } else {
             debugPrint("ERROR fetching recently viewed drawings: ${result.error}");
             emit(HomeScreenFetchErrorState("Failed to load recently viewed drawings: ${result.error}"));
           }
  } catch (e) {
    debugPrint("ERROR in _fetchHomeScreenContent: $e");
    emit(HomeScreenFetchErrorState(e.toString()));
  }
}

  void _listenToEvents(ListenToEventsEvent event, Emitter<HomeScreenState> emit) {
    startListeningGlobalEvenets();
  }
}

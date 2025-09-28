import 'package:ardennes/libraries/core_ui/event_bus.dart';
import 'package:ardennes/libraries/drawing/drawing_catalog_loader.dart';
import 'package:ardennes/libraries/drawing/recently_viewed_drawing_provider.dart';
import 'package:ardennes/models/drawings/drawings_catalog_data.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawings_catalog_event.dart';
import 'drawings_catalog_state.dart';

class DrawingsCatalogBloc
    extends Bloc<DrawingsCatalogEvent, DrawingsCatalogState> {
  DrawingsCatalogUIState savedUiState = DrawingsCatalogUIState();
  ProjectMetadata? savedSelectedProject;
  final DrawingCatalogService drawingCatalogService;
  final RecentlyViewedService recentlyViewedService;
  final EventBus _eventBus = EventBus();

  DrawingsCatalogBloc({
    required this.drawingCatalogService,
    required this.recentlyViewedService,
  }) : super(DrawingsCatalogState().init()) {
    on<InitEvent>(_init);
    on<FetchDrawingsCatalogEvent>(_fetchDrawingCatalog);
    on<UpdateSelectedCollectionEvent>(_updateSelectedCollection);
    on<UpdateSelectedDisciplineEvent>(_updateSelectedDiscipline);
    on<UpdateSelectedTagEvent>(_updateSelectedTag);
    on<UpdateSelectedVersionEvent>(_updateSelectedVersion);
    on<SaveRecentlyViewedDrawingEvent>(_saveRecentlyViewedDrawing);
  }

  void _init(InitEvent event, Emitter<DrawingsCatalogState> emit) async {
    emit(state.clone());
  }

  void _updateSelectedVersion(
      UpdateSelectedVersionEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedVersion = event.selectedVersion;
    _updateSelected(emit);
  }

  void _updateSelectedCollection(
      UpdateSelectedCollectionEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedCollection = event.selectedCollection;
    _updateSelected(emit);
  }

  void _updateSelectedDiscipline(
      UpdateSelectedDisciplineEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedDiscipline = event.selectedDiscipline;
    _updateSelected(emit);
  }

  void _updateSelectedTag(
      UpdateSelectedTagEvent event, Emitter<DrawingsCatalogState> emit) {
    savedUiState.selectedTag = event.selectedTag;
    _updateSelected(emit);
  }

  void _updateSelected(Emitter<DrawingsCatalogState> emit) {
    final state = this.state;
    if (state is FetchedDrawingsCatalogState) {
      final filteredItems = state.drawingsCatalog.drawingItems.where((item) {
        return (savedUiState.selectedVersion == null ||
                item.versionId == savedUiState.selectedVersion?.id) &&
            (savedUiState.selectedCollection == null ||
                item.collection == savedUiState.selectedCollection?.name) &&
            (savedUiState.selectedDiscipline == null ||
                item.discipline == savedUiState.selectedDiscipline?.name) &&
            (savedUiState.selectedTag == null ||
                item.tags.contains(savedUiState.selectedTag?.name));
      }).toList();
      emit(FetchedDrawingsCatalogState(
          drawingsCatalog: state.drawingsCatalog,
          displayedItems: filteredItems,
          uiState: savedUiState));
    }
  }

  void _fetchDrawingCatalog(FetchDrawingsCatalogEvent event,
      Emitter<DrawingsCatalogState> emit) async {
    try {
      DrawingsCatalogData? drawingsCatalog = await drawingCatalogService
          .fetchDrawingCatalog(event.selectedProject);
      if (drawingsCatalog != null) {
        savedSelectedProject = event.selectedProject;
        emit(FetchedDrawingsCatalogState(
          drawingsCatalog: drawingsCatalog,
          displayedItems: drawingsCatalog.drawingItems,
          uiState: savedUiState,
        ));
      } else {
        emit(DrawingsCatalogFetchErrorState("Project id doesn't exist"));
      }
    } catch (e) {
      emit(DrawingsCatalogFetchErrorState(e.toString()));
    }
  }

  void _saveRecentlyViewedDrawing(SaveRecentlyViewedDrawingEvent event,
      Emitter<DrawingsCatalogState> emit) async {
    try {
      await recentlyViewedService.saveDrawing(
        selectedProject: event.selectedProject,
        drawing: event.drawing,
      );
      
      _eventBus.fire(RecentlyViewedUpdatedEvent(event.selectedProject.id!));
    } catch (e) {
      print('Error saving recently viewed drawing: $e');
    }
  }
}

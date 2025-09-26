import 'package:ardennes/features/home_screen/event.dart';
import 'package:ardennes/features/home_screen/state.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreenEvent', () {
    test('InitEvent should be created correctly', () {
      final event = InitEvent();
      
      expect(event, isA<InitEvent>());
    });

    test('FetchHomeScreenContentEvent should be created with correct project', () { 
      final project = ProjectMetadata(
        id: 'test-project',
        name: 'Test Project',
      );
      
      final event = FetchHomeScreenContentEvent(project);
      
      expect(event, isA<FetchHomeScreenContentEvent>());
      expect(event.selectedProject, equals(project));
    });
  });

  group('HomeScreenState', () {
    test('HomeScreenState should be created correctly', () {
      final state = HomeScreenState();
      
      expect(state, isA<HomeScreenState>());
    });

    test('HomeScreenState init should return HomeScreenState', () {
       
      final state = HomeScreenState();
      
      final initState = state.init();
      
      expect(initState, isA<HomeScreenState>());
    });

    test('HomeScreenState clone should return HomeScreenState', () {
       
      final state = HomeScreenState();
      
      final clonedState = state.clone();
      
      expect(clonedState, isA<HomeScreenState>());
    });

    test('FetchingHomeScreenContentState should be created correctly', () {
      final state = FetchingHomeScreenContentState();
      
      expect(state, isA<FetchingHomeScreenContentState>());
      expect(state, isA<HomeScreenState>());
    });

    test('FetchingHomeScreenContentState clone should return FetchingHomeScreenContentState', () {
       
      final state = FetchingHomeScreenContentState();
      
      final clonedState = state.clone();
      
      expect(clonedState, isA<FetchingHomeScreenContentState>());
    });

    test('FetchedHomeScreenContentState should be created with drawings', () {
       
      final drawings = [
        RecentlyViewedDrawingTile(
          title: 'Drawing 1',
          subtitle: 'Collection 1',
          drawingThumbnailUrl: 'https://example.com/image1.jpg',
        ),
        RecentlyViewedDrawingTile(
          title: 'Drawing 2',
          subtitle: 'Collection 2',
          drawingThumbnailUrl: 'https://example.com/image2.jpg',
        ),
      ];
      
      final state = FetchedHomeScreenContentState(recentlyViewedDrawingTiles: drawings);
    
      expect(state, isA<FetchedHomeScreenContentState>());
      expect(state, isA<HomeScreenState>());
      expect(state.recentlyViewedDrawingTiles, equals(drawings));
      expect(state.recentlyViewedDrawingTiles.length, equals(2));
    });

    test('FetchedHomeScreenContentState clone should return FetchedHomeScreenContentState', () {
       
      final drawings = [
        RecentlyViewedDrawingTile(
          title: 'Drawing 1',
          subtitle: 'Collection 1',
          drawingThumbnailUrl: 'https://example.com/image1.jpg',
        ),
      ];
      final state = FetchedHomeScreenContentState(recentlyViewedDrawingTiles: drawings);
      
      final clonedState = state.clone();
    
      expect(clonedState, isA<FetchedHomeScreenContentState>());
      expect(clonedState.recentlyViewedDrawingTiles, equals(drawings));
    });

    test('HomeScreenFetchErrorState should be created with error message', () {
       
      const errorMessage = 'Test error message';
      
      final state = HomeScreenFetchErrorState(errorMessage);
      
      expect(state, isA<HomeScreenFetchErrorState>());
      expect(state, isA<HomeScreenState>());
      expect(state.errorMessage, equals(errorMessage));
    });

    test('HomeScreenFetchErrorState clone should return HomeScreenFetchErrorState', () {
       
      const errorMessage = 'Test error message';
      final state = HomeScreenFetchErrorState(errorMessage);
      
      final clonedState = state.clone();
      
      expect(clonedState, isA<HomeScreenFetchErrorState>());
      expect(clonedState.errorMessage, equals(errorMessage));
    });
  });

  group('RecentlyViewedDrawingTile', () {
    test('should be created with correct properties', () {
       
      const title = 'Test Drawing';
      const subtitle = 'Test Collection';
      const drawingThumbnailUrl = 'https://example.com/image.jpg';
      
      final drawing = RecentlyViewedDrawingTile(
        title: title,
        subtitle: subtitle,
        drawingThumbnailUrl: drawingThumbnailUrl,
      );
      
      expect(drawing.title, equals(title));
      expect(drawing.subtitle, equals(subtitle));
      expect(drawing.drawingThumbnailUrl, equals(drawingThumbnailUrl));
    });

    test('should handle empty strings', () {
      final drawing = RecentlyViewedDrawingTile(
        title: '',
        subtitle: '',
        drawingThumbnailUrl: '',
      );
      
      expect(drawing.title, equals(''));
      expect(drawing.subtitle, equals(''));
      expect(drawing.drawingThumbnailUrl, equals(''));
    });

    test('should handle empty strings correctly', () {
      final drawing = RecentlyViewedDrawingTile(
        title: '',
        subtitle: '',
        drawingThumbnailUrl: '',
      );

      expect(drawing.title, isEmpty);
      expect(drawing.subtitle, isEmpty);
      expect(drawing.drawingThumbnailUrl, isEmpty);
    });
  });
}

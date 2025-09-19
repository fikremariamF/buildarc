import 'package:ardennes/features/home_screen/event.dart';
import 'package:ardennes/features/home_screen/state.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreenEvent', () {
    test('InitEvent should be created correctly', () {
      // Act
      final event = InitEvent();
      
      // Assert
      expect(event, isA<InitEvent>());
    });

    test('FetchHomeScreenContentEvent should be created with correct project', () {
      // Arrange
      final project = ProjectMetadata(
        id: 'test-project',
        name: 'Test Project',
      );
      
      // Act
      final event = FetchHomeScreenContentEvent(project);
      
      // Assert
      expect(event, isA<FetchHomeScreenContentEvent>());
      expect(event.selectedProject, equals(project));
    });
  });

  group('HomeScreenState', () {
    test('HomeScreenState should be created correctly', () {
      // Act
      final state = HomeScreenState();
      
      // Assert
      expect(state, isA<HomeScreenState>());
    });

    test('HomeScreenState init should return HomeScreenState', () {
      // Arrange
      final state = HomeScreenState();
      
      // Act
      final initState = state.init();
      
      // Assert
      expect(initState, isA<HomeScreenState>());
    });

    test('HomeScreenState clone should return HomeScreenState', () {
      // Arrange
      final state = HomeScreenState();
      
      // Act
      final clonedState = state.clone();
      
      // Assert
      expect(clonedState, isA<HomeScreenState>());
    });

    test('FetchingHomeScreenContentState should be created correctly', () {
      // Act
      final state = FetchingHomeScreenContentState();
      
      // Assert
      expect(state, isA<FetchingHomeScreenContentState>());
      expect(state, isA<HomeScreenState>());
    });

    test('FetchingHomeScreenContentState clone should return FetchingHomeScreenContentState', () {
      // Arrange
      final state = FetchingHomeScreenContentState();
      
      // Act
      final clonedState = state.clone();
      
      // Assert
      expect(clonedState, isA<FetchingHomeScreenContentState>());
    });

    test('FetchedHomeScreenContentState should be created with drawings', () {
      // Arrange
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
      
      // Act
      final state = FetchedHomeScreenContentState(recentlyViewedDrawingTiles: drawings);
      
      // Assert
      expect(state, isA<FetchedHomeScreenContentState>());
      expect(state, isA<HomeScreenState>());
      expect(state.recentlyViewedDrawingTiles, equals(drawings));
      expect(state.recentlyViewedDrawingTiles.length, equals(2));
    });

    test('FetchedHomeScreenContentState clone should return FetchedHomeScreenContentState', () {
      // Arrange
      final drawings = [
        RecentlyViewedDrawingTile(
          title: 'Drawing 1',
          subtitle: 'Collection 1',
          drawingThumbnailUrl: 'https://example.com/image1.jpg',
        ),
      ];
      final state = FetchedHomeScreenContentState(recentlyViewedDrawingTiles: drawings);
      
      // Act
      final clonedState = state.clone();
      
      // Assert
      expect(clonedState, isA<FetchedHomeScreenContentState>());
      expect(clonedState.recentlyViewedDrawingTiles, equals(drawings));
    });

    test('HomeScreenFetchErrorState should be created with error message', () {
      // Arrange
      const errorMessage = 'Test error message';
      
      // Act
      final state = HomeScreenFetchErrorState(errorMessage);
      
      // Assert
      expect(state, isA<HomeScreenFetchErrorState>());
      expect(state, isA<HomeScreenState>());
      expect(state.errorMessage, equals(errorMessage));
    });

    test('HomeScreenFetchErrorState clone should return HomeScreenFetchErrorState', () {
      // Arrange
      const errorMessage = 'Test error message';
      final state = HomeScreenFetchErrorState(errorMessage);
      
      // Act
      final clonedState = state.clone();
      
      // Assert
      expect(clonedState, isA<HomeScreenFetchErrorState>());
      expect(clonedState.errorMessage, equals(errorMessage));
    });
  });

  group('RecentlyViewedDrawingTile', () {
    test('should be created with correct properties', () {
      // Arrange
      const title = 'Test Drawing';
      const subtitle = 'Test Collection';
      const drawingThumbnailUrl = 'https://example.com/image.jpg';
      
      // Act
      final drawing = RecentlyViewedDrawingTile(
        title: title,
        subtitle: subtitle,
        drawingThumbnailUrl: drawingThumbnailUrl,
      );
      
      // Assert
      expect(drawing.title, equals(title));
      expect(drawing.subtitle, equals(subtitle));
      expect(drawing.drawingThumbnailUrl, equals(drawingThumbnailUrl));
    });

    test('should handle empty strings', () {
      // Act
      final drawing = RecentlyViewedDrawingTile(
        title: '',
        subtitle: '',
        drawingThumbnailUrl: '',
      );
      
      // Assert
      expect(drawing.title, equals(''));
      expect(drawing.subtitle, equals(''));
      expect(drawing.drawingThumbnailUrl, equals(''));
    });

    test('should handle empty strings correctly', () {
      // Act
      final drawing = RecentlyViewedDrawingTile(
        title: '',
        subtitle: '',
        drawingThumbnailUrl: '',
      );
      
      // Assert
      expect(drawing.title, isEmpty);
      expect(drawing.subtitle, isEmpty);
      expect(drawing.drawingThumbnailUrl, isEmpty);
    });
  });
}

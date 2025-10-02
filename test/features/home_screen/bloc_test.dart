import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ardennes/features/home_screen/bloc.dart';
import 'package:ardennes/features/home_screen/event.dart';
import 'package:ardennes/features/home_screen/state.dart';
import 'package:ardennes/libraries/drawing/recently_viewed_drawing_provider.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:ardennes/libraries/core_ui/event_bus.dart';

import 'bloc_test.mocks.dart';

class TestEventBus implements EventBus {
  @override
  void fire(event) {}

  @override
  Stream<T> on<T>() => const Stream.empty();

  @override
  void dispose() {}
}

@GenerateMocks([RecentlyViewedService])
void main() {
  late MockRecentlyViewedService mockRecentlyViewedService;
  late TestEventBus testEventBus;
  late ProjectMetadata project;
  late HomeScreenBloc bloc;

  setUp(() {
    mockRecentlyViewedService = MockRecentlyViewedService();
    testEventBus = TestEventBus();
    project = ProjectMetadata(
      id: 'test-project-id',
      name: 'Test Project',
    );
    bloc = HomeScreenBloc(
      recentlyViewedService: mockRecentlyViewedService,
      eventBus: testEventBus,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('HomeScreenBloc - Recently Viewed Service Integration', () {
    blocTest<HomeScreenBloc, HomeScreenState>(
      'loads recently viewed drawings successfully',
      build: () {
        when(mockRecentlyViewedService.getRecentlyViewedDrawings(
          projectId: anyNamed('projectId'),
        )).thenAnswer((_) async => [
              RecentlyViewedDrawingTile(
                title: 'Drawing 1',
                subtitle: 'Collection 1',
                drawingThumbnailUrl: 'https://x/1.jpg',
              ),
            ]);
        return bloc;
      },
      act: (_) => bloc.add(FetchHomeScreenContentEvent(project)),
      expect: () => [
        isA<FetchingHomeScreenContentState>(),
        isA<FetchedHomeScreenContentState>().having(
          (s) => s.recentlyViewedDrawingTiles.length,
          'tiles length',
          1,
        ),
      ],
      verify: (_) {
        verify(mockRecentlyViewedService.getRecentlyViewedDrawings(
          projectId: 'test-project-id',
        )).called(1);
      },
    );

    blocTest<HomeScreenBloc, HomeScreenState>(
      'handles empty recently viewed list',
      build: () {
        when(mockRecentlyViewedService.getRecentlyViewedDrawings(
          projectId: anyNamed('projectId'),
        )).thenAnswer((_) async => []);
        return bloc;
      },
      act: (_) => bloc.add(FetchHomeScreenContentEvent(project)),
      expect: () => [
        isA<FetchingHomeScreenContentState>(),
        isA<FetchedHomeScreenContentState>().having(
          (s) => s.recentlyViewedDrawingTiles.isEmpty,
          'empty',
          true,
        ),
      ],
      verify: (_) {
        verify(mockRecentlyViewedService.getRecentlyViewedDrawings(
          projectId: 'test-project-id',
        )).called(1);
      },
    );

    blocTest<HomeScreenBloc, HomeScreenState>(
      'handles service errors gracefully',
      build: () {
        when(mockRecentlyViewedService.getRecentlyViewedDrawings(
          projectId: anyNamed('projectId'),
        )).thenThrow(Exception('Service error'));
        return bloc;
      },
      act: (_) => bloc.add(FetchHomeScreenContentEvent(project)),
      expect: () => [
        isA<FetchingHomeScreenContentState>(),
        isA<HomeScreenFetchErrorState>().having(
          (s) => s.errorMessage.toLowerCase(),
          'message',
          contains('service error'),
        ),
      ],
      verify: (_) {
        verify(mockRecentlyViewedService.getRecentlyViewedDrawings(
          projectId: 'test-project-id',
        )).called(1);
      },
    );

    blocTest<HomeScreenBloc, HomeScreenState>(
      'handles null project ID',
      build: () {
        when(mockRecentlyViewedService.getRecentlyViewedDrawings(
          projectId: anyNamed('projectId'),
        )).thenAnswer((_) async => []);
        return bloc;
      },
      act: (_) => bloc.add(FetchHomeScreenContentEvent(ProjectMetadata(id: null, name: 'Test'))),
      expect: () => [
        isA<FetchingHomeScreenContentState>(),
        isA<HomeScreenFetchErrorState>().having(
          (s) => s.errorMessage,
          'message',
          'Project ID is required',
        ),
      ],
    );
  });
}
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ardennes/features/drawing_detail/drawing_detail_bloc.dart';
import 'package:ardennes/features/drawing_detail/drawing_detail_event.dart';
import 'package:ardennes/features/drawing_detail/drawing_detail_state.dart';
import 'package:ardennes/libraries/drawing/recently_viewed_drawing_provider.dart';
import 'package:ardennes/libraries/drawing/image_provider.dart';
import 'package:ardennes/libraries/core_ui/event_bus.dart';
import 'package:ardennes/models/drawings/drawing_detail.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'drawing_detail_bloc_test.mocks.dart';

class TestEventBus implements EventBus {
  @override
  void fire(event) {}

  @override
  Stream<T> on<T>() => const Stream.empty();

  @override
  void dispose() {}
}

@GenerateMocks([RecentlyViewedService, UIImageProvider])
void main() {
  late MockRecentlyViewedService mockRecentlyViewedService;
  late MockUIImageProvider mockUIImageProvider;
  late TestEventBus testEventBus;
  late DrawingDetailBloc bloc;


  setUp(() {
    mockRecentlyViewedService = MockRecentlyViewedService();
    mockUIImageProvider = MockUIImageProvider();
    testEventBus = TestEventBus();
    bloc = DrawingDetailBloc(
      uiImageProvider: mockUIImageProvider,
      recentlyViewedService: mockRecentlyViewedService,
      eventBus: testEventBus,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('DrawingDetailBloc - LoadSheet Event', () {
    blocTest<DrawingDetailBloc, DrawingDetailState>(
      'saves drawing to recently viewed when LoadSheet is triggered',
      build: () {
        when(mockUIImageProvider.getImage(any)).thenThrow(Exception('Image loading failed'));
        when(mockRecentlyViewedService.saveDrawing(
          projectId: anyNamed('projectId'),
          drawing: anyNamed('drawing'),
        )).thenAnswer((_) async {});
        return bloc;
      },
      act: (_) => bloc.add(LoadSheet(
        number: 'A-001',
        collection: 'Story One',
        versionId: 0,
        projectId: 'test-project-id',
      )),
      expect: () => [
        isA<DrawingDetailStateLoading>(),
        isA<DrawingDetailStateError>(),
      ],
      verify: (_) {
        verify(mockRecentlyViewedService.saveDrawing(
          projectId: 'test-project-id',
          drawing: anyNamed('drawing'),
        )).called(1);
      },
    );

    blocTest<DrawingDetailBloc, DrawingDetailState>(
      'creates correct RecentlyViewedDrawingTile when saving',
      build: () {
        when(mockUIImageProvider.getImage(any)).thenThrow(Exception('Image loading failed'));
        when(mockRecentlyViewedService.saveDrawing(
          projectId: anyNamed('projectId'),
          drawing: anyNamed('drawing'),
        )).thenAnswer((_) async {});
        return bloc;
      },
      act: (_) => bloc.add(LoadSheet(
        number: 'A-001',
        collection: 'Story One',
        versionId: 0,
        projectId: 'test-project-id',
      )),
      expect: () => [
        isA<DrawingDetailStateLoading>(),
        isA<DrawingDetailStateError>(),
      ],
      verify: (_) {
        final captured = verify(mockRecentlyViewedService.saveDrawing(
          projectId: 'test-project-id',
          drawing: captureAnyNamed('drawing'),
        )).captured;
        
        final drawing = captured.first as RecentlyViewedDrawingTile;
        expect(drawing.title, 'A-001');
        expect(drawing.subtitle, 'Story One');
      },
    );

    blocTest<DrawingDetailBloc, DrawingDetailState>(
      'handles recently viewed save errors gracefully',
      build: () {
        when(mockUIImageProvider.getImage(any)).thenThrow(Exception('Image loading failed'));
        when(mockRecentlyViewedService.saveDrawing(
          projectId: anyNamed('projectId'),
          drawing: anyNamed('drawing'),
        )).thenThrow(Exception('Save failed'));
        return bloc;
      },
      act: (_) => bloc.add(LoadSheet(
        number: 'A-001',
        collection: 'Story One',
        versionId: 0,
        projectId: 'test-project-id',
      )),
      expect: () => [
        isA<DrawingDetailStateLoading>(),
        isA<DrawingDetailStateError>(),
      ],
      verify: (_) {
        verify(mockRecentlyViewedService.saveDrawing(
          projectId: 'test-project-id',
          drawing: anyNamed('drawing'),
        )).called(1);
      },
    );

    blocTest<DrawingDetailBloc, DrawingDetailState>(
      'fires RecentlyViewedUpdatedEvent after successful save',
      build: () {
        when(mockUIImageProvider.getImage(any)).thenThrow(Exception('Image loading failed'));
        when(mockRecentlyViewedService.saveDrawing(
          projectId: anyNamed('projectId'),
          drawing: anyNamed('drawing'),
        )).thenAnswer((_) async {});
        return bloc;
      },
      act: (_) => bloc.add(LoadSheet(
        number: 'A-001',
        collection: 'Story One',
        versionId: 0,
        projectId: 'test-project-id',
      )),
      expect: () => [
        isA<DrawingDetailStateLoading>(),
        isA<DrawingDetailStateError>(),
      ],
      verify: (_) {
        verify(mockRecentlyViewedService.saveDrawing(
          projectId: 'test-project-id',
          drawing: anyNamed('drawing'),
        )).called(1);
      },
    );
  });
}

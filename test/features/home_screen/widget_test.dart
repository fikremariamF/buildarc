import 'package:ardennes/features/home_screen/state.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecentlyViewedDrawings Basic Tests', () {
    testWidgets('should create RecentlyViewedDrawingTile widget', (WidgetTester tester) async {
      // Arrange
      final drawing = RecentlyViewedDrawingTile(
        title: 'Test Drawing',
        subtitle: 'Test Collection',
        drawingThumbnailUrl: 'https://example.com/image.jpg',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(drawing.title),
                Text(drawing.subtitle),
                Text(drawing.drawingThumbnailUrl),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Drawing'), findsOneWidget);
      expect(find.text('Test Collection'), findsOneWidget);
      expect(find.text('https://example.com/image.jpg'), findsOneWidget);
    });

    testWidgets('should handle empty strings in drawing tile', (WidgetTester tester) async {
      // Arrange
      final drawing = RecentlyViewedDrawingTile(
        title: '',
        subtitle: '',
        drawingThumbnailUrl: '',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(drawing.title),
                Text(drawing.subtitle),
                Text(drawing.drawingThumbnailUrl),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(''), findsNWidgets(3));
    });

    testWidgets('should handle long text in drawing tile', (WidgetTester tester) async {
      // Arrange
      const longTitle = 'Very Long Drawing Title That Should Be Handled Properly';
      const longSubtitle = 'Very Long Collection Name That Should Be Handled Properly';
      const longUrl = 'https://example.com/very/long/url/that/should/be/handled/properly/image.jpg';
      
      final drawing = RecentlyViewedDrawingTile(
        title: longTitle,
        subtitle: longSubtitle,
        drawingThumbnailUrl: longUrl,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(drawing.title),
                Text(drawing.subtitle),
                Text(drawing.drawingThumbnailUrl),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(longTitle), findsOneWidget);
      expect(find.text(longSubtitle), findsOneWidget);
      expect(find.text(longUrl), findsOneWidget);
    });

    testWidgets('should handle special characters in drawing tile', (WidgetTester tester) async {
      // Arrange
      final drawing = RecentlyViewedDrawingTile(
        title: 'Drawing with Special Characters: !@#\$%^&*()',
        subtitle: 'Collection with Special Characters: !@#\$%^&*()',
        drawingThumbnailUrl: 'https://example.com/image-with-special-chars-!@#\$.jpg',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(drawing.title),
                Text(drawing.subtitle),
                Text(drawing.drawingThumbnailUrl),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Drawing with Special Characters: !@#\$%^&*()'), findsOneWidget);
      expect(find.text('Collection with Special Characters: !@#\$%^&*()'), findsOneWidget);
      expect(find.text('https://example.com/image-with-special-chars-!@#\$.jpg'), findsOneWidget);
    });

    testWidgets('should handle unicode characters in drawing tile', (WidgetTester tester) async {
      // Arrange
      final drawing = RecentlyViewedDrawingTile(
        title: 'Drawing with Unicode: 中文 日本語 한국어',
        subtitle: 'Collection with Unicode: 中文 日本語 한국어',
        drawingThumbnailUrl: 'https://example.com/unicode-image-中文.jpg',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(drawing.title),
                Text(drawing.subtitle),
                Text(drawing.drawingThumbnailUrl),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Drawing with Unicode: 中文 日本語 한국어'), findsOneWidget);
      expect(find.text('Collection with Unicode: 中文 日本語 한국어'), findsOneWidget);
      expect(find.text('https://example.com/unicode-image-中文.jpg'), findsOneWidget);
    });

    testWidgets('should create a basic list view with drawings', (WidgetTester tester) async {
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
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: drawings.length,
              itemBuilder: (context, index) {
                final drawing = drawings[index];
                return ListTile(
                  title: Text(drawing.title),
                  subtitle: Text(drawing.subtitle),
                  leading: Text(drawing.drawingThumbnailUrl),
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Drawing 1'), findsOneWidget);
      expect(find.text('Drawing 2'), findsOneWidget);
      expect(find.text('Collection 1'), findsOneWidget);
      expect(find.text('Collection 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should handle empty drawings list', (WidgetTester tester) async {
      // Arrange
      final drawings = <RecentlyViewedDrawingTile>[];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: drawings.length,
              itemBuilder: (context, index) {
                final drawing = drawings[index];
                return ListTile(
                  title: Text(drawing.title),
                  subtitle: Text(drawing.subtitle),
                  leading: Text(drawing.drawingThumbnailUrl),
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });
  });
}

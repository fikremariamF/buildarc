import 'package:ardennes/features/home_screen/recently_viewed_service.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecentlyViewedService', () {
    test('should create RecentlyViewedDrawingTile with correct properties', () {
       
      final drawing = RecentlyViewedDrawingTile(
        title: 'Test Drawing',
        subtitle: 'Test Collection',
        drawingThumbnailUrl: 'https://example.com/image.jpg',
      );

      expect(drawing.title, equals('Test Drawing'));
      expect(drawing.subtitle, equals('Test Collection'));
      expect(drawing.drawingThumbnailUrl, equals('https://example.com/image.jpg'));
    });

    test('should handle empty strings in RecentlyViewedDrawingTile', () {
       
      final drawing = RecentlyViewedDrawingTile(
        title: '',
        subtitle: '',
        drawingThumbnailUrl: '',
      );

      expect(drawing.title, equals(''));
      expect(drawing.subtitle, equals(''));
      expect(drawing.drawingThumbnailUrl, equals(''));
    });

    test('should handle long strings in RecentlyViewedDrawingTile', () {
       
      const longTitle = 'Very Long Drawing Title That Should Be Handled Properly';
      const longSubtitle = 'Very Long Collection Name That Should Be Handled Properly';
      const longUrl = 'https://example.com/very/long/url/that/should/be/handled/properly/image.jpg';
      
      final drawing = RecentlyViewedDrawingTile(
        title: longTitle,
        subtitle: longSubtitle,
        drawingThumbnailUrl: longUrl,
      );

      expect(drawing.title, equals(longTitle));
      expect(drawing.subtitle, equals(longSubtitle));
      expect(drawing.drawingThumbnailUrl, equals(longUrl));
    });

    test('should create ProjectMetadata with correct properties', () {
       
      final project = ProjectMetadata(
        id: 'test-project-id',
        name: 'Test Project',
      );

      expect(project.id, equals('test-project-id'));
      expect(project.name, equals('Test Project'));
    });

    test('should handle special characters in drawing properties', () {
       
      final drawing = RecentlyViewedDrawingTile(
        title: 'Drawing with Special Characters: !@#\$%^&*()',
        subtitle: 'Collection with Special Characters: !@#\$%^&*()',
        drawingThumbnailUrl: 'https://example.com/image-with-special-chars-!@#\$.jpg',
      );

      expect(drawing.title, equals('Drawing with Special Characters: !@#\$%^&*()'));
      expect(drawing.subtitle, equals('Collection with Special Characters: !@#\$%^&*()'));
      expect(drawing.drawingThumbnailUrl, equals('https://example.com/image-with-special-chars-!@#\$.jpg'));
    });

    test('should handle unicode characters in drawing properties', () {
       
      final drawing = RecentlyViewedDrawingTile(
        title: 'Drawing with Unicode: 中文 日本語 한국어',
        subtitle: 'Collection with Unicode: 中文 日本語 한국어',
        drawingThumbnailUrl: 'https://example.com/unicode-image-中文.jpg',
      );

      expect(drawing.title, equals('Drawing with Unicode: 中文 日本語 한국어'));
      expect(drawing.subtitle, equals('Collection with Unicode: 中文 日本語 한국어'));
      expect(drawing.drawingThumbnailUrl, equals('https://example.com/unicode-image-中文.jpg'));
    });
  });
}

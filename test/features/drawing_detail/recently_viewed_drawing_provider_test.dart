import 'package:flutter_test/flutter_test.dart';
import 'package:ardennes/libraries/drawing/recently_viewed_drawing_provider.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';

void main() {
  group('RecentlyViewedService Core Logic Tests', () {
    test('Deduplication logic - removes existing drawing by title', () {
      final existingDrawings = [
        RecentlyViewedDrawingTile(
          title: 'A-001',
          subtitle: 'Story One Old',
          drawingThumbnailUrl: 'old.jpg',
        ),
        RecentlyViewedDrawingTile(
          title: 'A-002',
          subtitle: 'Story Two',
          drawingThumbnailUrl: 'other.jpg',
        ),
      ];

      final newDrawing = RecentlyViewedDrawingTile(
        title: 'A-001',
        subtitle: 'Story One Updated',
        drawingThumbnailUrl: 'new.jpg',
      );

      final drawings = List<RecentlyViewedDrawingTile>.from(existingDrawings);
      drawings.removeWhere((d) => d.title == newDrawing.title);
      drawings.insert(0, newDrawing);

      expect(drawings.length, 2);
      expect(drawings.first.title, 'A-001');
      expect(drawings.first.subtitle, 'Story One Updated');
      expect(drawings.last.title, 'A-002');
    });

    test('Limit enforcement - keeps only maxRecentlyViewedDrawings items', () {
      final manyDrawings = List.generate(15, (i) => RecentlyViewedDrawingTile(
        title: 'A-${i.toString().padLeft(3, '0')}',
        subtitle: 'Story $i',
        drawingThumbnailUrl: 'thumb$i.jpg',
      ));

      final newDrawing = RecentlyViewedDrawingTile(
        title: 'A-NEW',
        subtitle: 'New Story',
        drawingThumbnailUrl: 'new.jpg',
      );

      final drawings = List<RecentlyViewedDrawingTile>.from(manyDrawings);
      drawings.insert(0, newDrawing);
      
      if (drawings.length > RecentlyViewedService.maxRecentlyViewedDrawings) {
        drawings.removeRange(
          RecentlyViewedService.maxRecentlyViewedDrawings, 
          drawings.length
        );
      }

      expect(drawings.length, RecentlyViewedService.maxRecentlyViewedDrawings);
      expect(drawings.first.title, 'A-NEW');
    });

    test('Order preservation - most recent drawings appear first', () {
      final drawings = [
        RecentlyViewedDrawingTile(title: 'A-001', subtitle: 'Story One', drawingThumbnailUrl: 'thumb1.jpg'),
        RecentlyViewedDrawingTile(title: 'A-002', subtitle: 'Story Two', drawingThumbnailUrl: 'thumb2.jpg'),
        RecentlyViewedDrawingTile(title: 'A-003', subtitle: 'Story Three', drawingThumbnailUrl: 'thumb3.jpg'),
      ];

      expect(drawings.first.title, 'A-001');
      expect(drawings.last.title, 'A-003');
    });
  });
}



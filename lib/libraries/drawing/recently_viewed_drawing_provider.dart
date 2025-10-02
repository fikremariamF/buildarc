import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

abstract class RecentlyViewedServiceAbstract {
  Future<void> saveDrawing({
    required String projectId,
    required RecentlyViewedDrawingTile drawing,
  });

  Future<List<RecentlyViewedDrawingTile>> getRecentlyViewedDrawings({
    required String projectId,
  });
}

@injectable
class RecentlyViewedService extends RecentlyViewedServiceAbstract {
  @override
  Future<void> saveDrawing({
    required String projectId,
    required RecentlyViewedDrawingTile drawing,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    String userId = currentUser.uid;

    try {
      final docId = "project_${projectId}_user_$userId";

      DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
          .collection('home_screens')
          .doc(docId);

      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await docRef.get();
      
      List<RecentlyViewedDrawingTile> currentDrawings = [];
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data['drawings'] is List) {
          currentDrawings = (data['drawings'] as List)
              .map((drawingMap) => RecentlyViewedDrawingTile(
                    title: drawingMap['title'],
                    subtitle: drawingMap['subtitle'],
                    drawingThumbnailUrl: drawingMap['drawingThumbnailUrl'],
                  ))
              .toList();
        }
        
        currentDrawings.removeWhere((d) => 
          d.title == drawing.title);
      }
      
      currentDrawings.insert(0, drawing);

      final maxRecentlyViewedDrawings = 10;
      
      if (currentDrawings.length > maxRecentlyViewedDrawings) {
        currentDrawings = currentDrawings.take(10).toList();
      }
      
      final dataToSave = {
        'user_id': userId,
        'project_id': projectId,
        'drawings': currentDrawings.map((drawing) => {
          'title': drawing.title,
          'subtitle': drawing.subtitle,
          'drawingThumbnailUrl': drawing.drawingThumbnailUrl,
        }).toList(),
      };

      await docRef.set(dataToSave);
          
    } catch (e) {
      debugPrint('Error saving recently viewed drawing: $e');
    }
  }

  @override
  Future<List<RecentlyViewedDrawingTile>> getRecentlyViewedDrawings({
    required String projectId,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }

    String userId = currentUser.uid;

    try {
      final docId = "project_${projectId}_user_$userId";

      DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
          .collection('home_screens')
          .doc(docId);

      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await docRef.get();
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data['drawings'] is List) {
          return (data['drawings'] as List)
              .map((drawingMap) => RecentlyViewedDrawingTile(
                    title: drawingMap['title'],
                    subtitle: drawingMap['subtitle'],
                    drawingThumbnailUrl: drawingMap['drawingThumbnailUrl'],
                  ))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching recently viewed drawings: $e');
      return [];
    }
  }
}

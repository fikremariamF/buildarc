import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class RecentlyViewedService {
  Future<void> saveDrawing({
    required ProjectMetadata selectedProject,
    required RecentlyViewedDrawingTile drawing,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    String userId = currentUser.uid;

    try {
      final docId = "project_${selectedProject.id}_user_$userId";

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
        
        // Remove the drawing if it already exists (to re-insert at the top)
        currentDrawings.removeWhere((d) => 
          d.title == drawing.title);
      }
      
      // Add the new drawing at the beginning
      currentDrawings.insert(0, drawing);
      
      // Limit to a reasonable number of recent drawings (e.g., 10)
      if (currentDrawings.length > 10) {
        currentDrawings = currentDrawings.take(10).toList();
      }
      
      // Create the data to save
      final dataToSave = {
        'user_id': userId,
        'project_id': selectedProject.id,
        'drawings': currentDrawings.map((drawing) => {
          'title': drawing.title,
          'subtitle': drawing.subtitle,
          'drawingThumbnailUrl': drawing.drawingThumbnailUrl,
        }).toList(),
      };

      // Save the document (this will create or update)
      await docRef.set(dataToSave);
          
    } catch (e) {
      debugPrint('Error saving recently viewed drawing: $e');
    }
  }

  Future<List<RecentlyViewedDrawingTile>> getRecentlyViewedDrawings({
    required ProjectMetadata selectedProject,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }

    String userId = currentUser.uid;

    try {
      final docId = "project_${selectedProject.id}_user_$userId";

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

import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// A simple result wrapper for service operations that can either succeed or fail.
/// 
/// This class provides a clean way to handle service operations without throwing
/// exceptions, making error handling explicit and predictable.
class ServiceResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ServiceResult._(this.data, this.error, this.isSuccess);

  factory ServiceResult.success(T data) => ServiceResult._(data, null, true);
  factory ServiceResult.error(String error) => ServiceResult._(null, error, false);
}

abstract class RecentlyViewedServiceAbstract {
  /// Saves a drawing to the recently viewed list for a project.
  /// 
  /// The drawing will be added to the top of the recently viewed list.
  /// If the same drawing already exists (based on title), it will be moved to the top.
  /// The list is automatically limited to [maxRecentlyViewedDrawings] items.
  Future<ServiceResult<void>> saveDrawing({
    required String projectId,
    required RecentlyViewedDrawingTile drawing,
  });

  /// Retrieves the recently viewed drawings for a project.
  /// 
  /// Returns an empty list if no drawings have been viewed or if the user
  /// is not authenticated.
  Future<ServiceResult<List<RecentlyViewedDrawingTile>>> getRecentlyViewedDrawings({
    required String projectId,
  });
}

/// Service for managing recently viewed drawings in Firestore.
/// 
/// **Firestore Structure**:
/// - Collection: `home_screens`
/// - Document ID: `project_{projectId}_user_{userId}`
/// - Fields: `user_id`, `project_id`, `drawings` (array)
@injectable
class RecentlyViewedService extends RecentlyViewedServiceAbstract {
  /// Maximum number of recently viewed drawings to keep per project.
  static const int maxRecentlyViewedDrawings = 10;
  
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  RecentlyViewedService(this._auth, this._firestore);

  @override
  Future<ServiceResult<void>> saveDrawing({
    required String projectId,
    required RecentlyViewedDrawingTile drawing,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return ServiceResult.error('User not authenticated');
    }

    try {
      final docId = "project_${projectId}_user_${currentUser.uid}";
      final docRef = _firestore.collection('home_screens').doc(docId);

      // Fetch existing drawings
      final docSnapshot = await docRef.get();
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
        
        // Remove existing drawing with same title (deduplication)
        currentDrawings.removeWhere((d) => d.title == drawing.title);
      }
      
      // Add new drawing to the top of the list
      currentDrawings.insert(0, drawing);
      
      // Enforce maximum list size
      if (currentDrawings.length > maxRecentlyViewedDrawings) {
        currentDrawings = currentDrawings.take(maxRecentlyViewedDrawings).toList();
      }
      
      // Prepare data for Firestore
      final dataToSave = {
        'user_id': currentUser.uid,
        'project_id': projectId,
        'drawings': currentDrawings.map((drawing) => {
          'title': drawing.title,
          'subtitle': drawing.subtitle,
          'drawingThumbnailUrl': drawing.drawingThumbnailUrl,
        }).toList(),
      };

      // Save to Firestore (overwrites entire document)
      await docRef.set(dataToSave);
      return ServiceResult.success(null);
    } catch (e) {
      debugPrint('Error saving recently viewed drawing: $e');
      return ServiceResult.error('Failed to save recently viewed drawing: $e');
    }
  }

  @override
  Future<ServiceResult<List<RecentlyViewedDrawingTile>>> getRecentlyViewedDrawings({
    required String projectId,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return ServiceResult.error('User not authenticated');
    }

    try {
      final docId = "project_${projectId}_user_${currentUser.uid}";
      final docRef = _firestore.collection('home_screens').doc(docId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data['drawings'] is List) {
          final drawings = (data['drawings'] as List)
              .map((drawingMap) => RecentlyViewedDrawingTile(
                    title: drawingMap['title'],
                    subtitle: drawingMap['subtitle'],
                    drawingThumbnailUrl: drawingMap['drawingThumbnailUrl'],
                  ))
              .toList();
          return ServiceResult.success(drawings);
        }
      }
      
      // Return empty list if no drawings found
      return ServiceResult.success([]);
    } catch (e) {
      debugPrint('Error fetching recently viewed drawings: $e');
      return ServiceResult.error('Failed to fetch recently viewed drawings: $e');
    }
  }
}
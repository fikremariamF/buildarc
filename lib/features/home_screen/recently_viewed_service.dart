import 'package:ardennes/features/home_screen/state.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:ardennes/models/screens/home_screen_data.dart';
import 'package:ardennes/features/home_screen/bloc.dart';
import 'package:ardennes/features/home_screen/event.dart';
import 'package:ardennes/injection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentlyViewedService {
  static void saveDrawing({
    required BuildContext context,
    required ProjectMetadata selectedProject,
    required RecentlyViewedDrawingTile drawing,
  }) {

    _saveDrawingDirectly(selectedProject, drawing).then((_) {
      try {
        final homeScreenBloc = context.read<HomeScreenBloc>();
        final currentState = homeScreenBloc.state;
        if (currentState is FetchedHomeScreenContentState) {
          List<RecentlyViewedDrawingTile> updatedDrawings = List.from(currentState.recentlyViewedDrawingTiles);
          
          updatedDrawings.removeWhere((d) => d.title == drawing.title && d.subtitle == drawing.subtitle);
          
          updatedDrawings.insert(0, drawing);
          
          if (updatedDrawings.length > 10) {
            updatedDrawings = updatedDrawings.take(10).toList();
          }
          
          homeScreenBloc.add(FetchHomeScreenContentEvent(selectedProject));
        }
      } catch (e) {
        debugPrint('Could not update state: $e');
      }
    }).catchError((error) {
      debugPrint('Error saving drawing: $error');
    });
  }

  static Future<void> _saveDrawingDirectly(
    ProjectMetadata selectedProject,
    RecentlyViewedDrawingTile drawing,
  ) async {
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
        // Get existing drawings from raw data
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
          d.title == drawing.title && 
          d.subtitle == drawing.subtitle);
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
      
      // Try to trigger a refetch of the home screen data only after successful save
      try {
        final homeScreenBloc = getIt<HomeScreenBloc>();
        homeScreenBloc.add(FetchHomeScreenContentEvent(selectedProject));
      } catch (e) {
        debugPrint('Could not trigger home screen refetch: $e');
      }
          
    } catch (e) {
      debugPrint('Error saving recently viewed drawing directly: $e');
    }
  }
}

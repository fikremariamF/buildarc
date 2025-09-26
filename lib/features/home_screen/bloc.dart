import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ardennes/models/screens/home_screen_data.dart';
import 'event.dart';
import 'state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  ProjectMetadata? _currentSelectedProject;

  HomeScreenBloc() : super(HomeScreenState().init()) {
    on<InitEvent>(_init);
    on<FetchHomeScreenContentEvent>(_fetchHomeScreenContent);
  }

  void _init(InitEvent event, Emitter<HomeScreenState> emit) async {
    emit(state.clone());
  }

  void _fetchHomeScreenContent(
      FetchHomeScreenContentEvent event, Emitter<HomeScreenState> emit) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return emit(HomeScreenFetchErrorState("User doesn't exist"));
    }

    emit(FetchingHomeScreenContentState());
    _currentSelectedProject = event.selectedProject;
    String userId = currentUser.uid;
    
    final docId = "project_${event.selectedProject.id}_user_$userId";
    DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
        .collection('home_screens')
        .doc(docId);

    
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await docRef.get(
        const GetOptions(source: Source.server)
      );
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        
        // Parse the drawings from the raw data
        List<RecentlyViewedDrawingTile> drawings = [];
        if (data['drawings'] is List) {
          try {
            drawings = (data['drawings'] as List)
                .map((drawingMap) {
                  return RecentlyViewedDrawingTile(
                    title: drawingMap['title'] ?? '',
                    subtitle: drawingMap['subtitle'] ?? '',
                    drawingThumbnailUrl: drawingMap['drawingThumbnailUrl'] ?? '',
                  );
                })
                .toList();
          } catch (parseError) {
            debugPrint("ERROR parsing drawings: $parseError");
          }
        }
        
        emit(FetchedHomeScreenContentState(recentlyViewedDrawingTiles: drawings));
        return;
      } else {
        debugPrint("ERROR: No home screen data found for project ${event.selectedProject.id}");
        emit(HomeScreenFetchErrorState("No data found for this project"));
      }
    } catch (e) {
      debugPrint("ERROR in _fetchHomeScreenContent: $e");
      emit(HomeScreenFetchErrorState(e.toString()));
    }
  }


}

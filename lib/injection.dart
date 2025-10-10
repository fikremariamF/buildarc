import 'package:ardennes/features/drawings_catalog/drawings_catalog_bloc.dart';
import 'package:ardennes/features/drawing_detail/drawing_detail_bloc.dart';
import 'package:ardennes/features/home_screen/bloc.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/core_ui/event_bus.dart';
import 'package:ardennes/libraries/drawing/drawing_catalog_loader.dart';
import 'package:ardennes/libraries/drawing/image_provider.dart';
import 'package:ardennes/libraries/drawing/recently_viewed_drawing_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

abstract class Env {
  static const dev = 'dev';
  static const prod = 'prod';
}

@module
abstract class RegisterModule {
  @factoryMethod
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @factoryMethod
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @factoryMethod
  DrawingsCatalogBloc get drawingsCatalogBloc =>
      DrawingsCatalogBloc(
        drawingCatalogService: getIt<DrawingCatalogService>(),
      );

  @factoryMethod
  DrawingDetailBloc get drawingDetailBloc =>
      DrawingDetailBloc(
        uiImageProvider: getIt<UIImageProvider>(),
        recentlyViewedService: getIt<RecentlyViewedService>(),
        eventBus: getIt<EventBus>(),
      );

  @factoryMethod
  AccountContextBloc get accountContextBloc => AccountContextBloc();

  @factoryMethod
  HomeScreenBloc get homeScreenBloc =>
      HomeScreenBloc(
        recentlyViewedService: getIt<RecentlyViewedService>(),
        eventBus: getIt<EventBus>(),
      );
}

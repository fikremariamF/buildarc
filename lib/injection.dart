import 'package:ardennes/features/drawings_catalog/drawings_catalog_bloc.dart';
import 'package:ardennes/features/drawing_detail/drawing_detail_bloc.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/drawing/drawing_catalog_loader.dart';
import 'package:ardennes/libraries/drawing/image_provider.dart';
import 'package:ardennes/libraries/drawing/recently_viewed_drawing_provider.dart';
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
  DrawingsCatalogBloc get drawingsCatalogBloc =>
      DrawingsCatalogBloc(
        drawingCatalogService: getIt<DrawingCatalogService>(),
        recentlyViewedService: getIt<RecentlyViewedService>(),
      );

  @factoryMethod
  DrawingDetailBloc get drawingDetailBloc =>
      DrawingDetailBloc(
        uiImageProvider: getIt<UIImageProvider>(),
        recentlyViewedService: getIt<RecentlyViewedService>(),
      );

  @factoryMethod
  AccountContextBloc get accountContextBloc => AccountContextBloc();
}

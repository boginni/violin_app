import 'package:custom_go_router/custom_go_router.dart';
import 'package:flutter/material.dart';

import '../app/app_dependencies.dart';
import 'controllers/tuner_controller.dart';
import 'controllers/tuner_store.dart';
import 'pages/tuner_page.dart';

class TunerRouteConfig extends AppRouteConfig {
  static const basePath = 'tuner';

  @override
  final fullPath = '/$basePath';

  @override
  bool hasValidParams(Map<String, String> params, {Object? extra}) {
    return true;
  }

  @override
  AppRoute getRouteFromParams(Map<String, String> params) {
    return TunerRoute();
  }
}

class TunerRoute extends AppRoute {
  TunerRoute();

  late final store = TunerStore();

  late final controller = TunerController(
    AppDependencies.get(),
    store: store,
  );

  @override
  String toPath() => Uri(
    path: '/${TunerRouteConfig.basePath}',
  ).toString();

  @override
  Widget toScreen({Object? extra}) {
    return TunerPage(
      controller: controller,
    );
  }
}

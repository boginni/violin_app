import 'package:custom_go_router/custom_go_router.dart';
import 'package:flutter/material.dart';
import 'package:violin_app/src/ui/tuner/controllers/tuner_store.dart';
import 'package:violin_app/src/ui/tuner/tuner_routes.dart';

import '../app/app_dependencies.dart';
import '../home/controllers/home_controller.dart';
import '../home/controllers/home_store.dart';
import '../home/controllers/shorten_history_store.dart';
import '../tuner/controllers/tuner_controller.dart';
import 'controller/shell_controller.dart';
import 'controller/shell_store.dart';
import 'shell_page.dart';

class ShellRouteConfig extends AppRouteConfig {
  static const basePath = 'shell';

  @override
  final fullPath = '/$basePath';

  @override
  bool hasValidParams(Map<String, String> params, {Object? extra}) {
    return true;
  }

  @override
  AppRoute getRouteFromParams(Map<String, String> params) {
    return ShellRoute();
  }
}

class ShellRoute extends AppRoute {
  ShellRoute();

  late final store = ShellStore();
  late final homeStore = HomeStore();
  late final tunerStore = TunerStore();
  late final shortenHistoryStore = ShortenHistoryStore();

  late final shellController = ShellController(
    appController: AppDependencies.get(),
    store: store,
    tunerController: TunerController(
      AppDependencies.get(),
      store: tunerStore,
    ),
    homeController: HomeController(
      AppDependencies.get(),
      AppDependencies.get(),
      store: homeStore,
      shortenHistoryStore: shortenHistoryStore,
    ),
  );

  @override
  String toPath() => Uri(
    path: '/${ShellRouteConfig.basePath}',
  ).toString();

  @override
  Widget toScreen({Object? extra}) {
    return ShellPage(
      controller: shellController,
    );
  }
}

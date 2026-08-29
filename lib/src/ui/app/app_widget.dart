import 'package:flutter/material.dart';
import 'package:violin_design_system/violin_design_system.dart';
import 'package:violin_l10n/violin_l10n.dart';

import 'app_dependencies.dart';
import 'controllers/app_controller.dart';
import 'material_theme.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  final theme = const MaterialTheme();

  @override
  void initState() {
    super.initState();
    AppDependencies.registerSingleton(widget.controller);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        init();
      },
    );
  }

  void init() {}

  ThemeData get lightTheme => theme.getTheme(
    ThemeData.light(useMaterial3: true),
  );

  ThemeData get darkTheme => theme.getTheme(
    ThemeData.dark(useMaterial3: true),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.store,
      builder: (context, value, child) {
        return MaterialApp.router(
          title: 'Violin App',
          locale: value.locale,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: value.themeMode,
          supportedLocales: ViolinL10n.supportedLocales,
          localizationsDelegates: ViolinL10n.localizationsDelegates,
          routerConfig: widget.controller.appRoutes.routes,
          builder: (context, child) => ThemeRegistry(
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            child: child ?? const Offstage(),
          ),
        );
      },
    );
  }
}

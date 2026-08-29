import 'package:flutter/material.dart';

class InverseBrightnessBuilder extends StatelessWidget {
  const InverseBrightnessBuilder({
    super.key,
    this.reverseBrightness = true,
    required this.builder,
  });

  final bool reverseBrightness;
  final Widget Function(BuildContext context, ThemeData theme) builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentBrightness = theme.brightness;

    final registry = ThemeRegistry.of(context);

    final isLight = currentBrightness == Brightness.light;

    final invertedTheme = reverseBrightness
        ? (isLight ? registry.darkTheme : registry.lightTheme)
        : theme;

    return Theme(
      data: invertedTheme,
      child: Builder(
        builder: (context) => builder(
          context,
          invertedTheme,
        ),
      ),
    );
  }
}

class ThemeRegistry extends InheritedWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeRegistry({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
    required super.child,
  });

  static ThemeRegistry of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ThemeRegistry>();
    assert(
      result != null,
      'No ThemeRegistry found in context. Wrap your app in one.',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeRegistry oldWidget) {
    return lightTheme != oldWidget.lightTheme ||
        darkTheme != oldWidget.darkTheme;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:violin_app/src/ui/home/components/home_header_component.dart';

import '../../../../material_app_testing.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();

  Widget buildGoldenWrapper(Widget child) {
    return MaterialAppTesting(
      builder: (context) {
        return Center(
          child: RepaintBoundary(
            child: Column(
              mainAxisSize: .min,
              children: [
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  group('HomeHeaderComponent Golden Tests', () {
    late GlobalKey<FormState> formKey;
    late TextEditingController urlController;

    setUp(() {
      formKey = GlobalKey<FormState>();
      urlController = TextEditingController();
    });

    tearDown(() {
      urlController.dispose();
    });

    testWidgets(
      'given default params '
      'when widget is rendered '
      'then returns initial state golden',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildGoldenWrapper(
            HomeHeaderComponent(
              formKey: formKey,
              urlController: urlController,
              onShortenUrl: () {},
              validator: (value) => null,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(HomeHeaderComponent),
          matchesGoldenFile('goldens/home_header_initial_state.png'),
        );
      },
    );

    testWidgets(
      'given url input string '
      'when user types text '
      'then returns clear icon state golden',
      (WidgetTester tester) async {
        urlController.text = 'https://example.com';

        await tester.pumpWidget(
          buildGoldenWrapper(
            HomeHeaderComponent(
              formKey: formKey,
              urlController: urlController,
              onShortenUrl: () {},
              validator: (value) => null,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(HomeHeaderComponent),
          matchesGoldenFile('goldens/home_header_with_text.png'),
        );
      },
    );

    testWidgets(
      'given isLoading as true '
      'when widget is rendered '
      'then returns loading state golden',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildGoldenWrapper(
            HomeHeaderComponent(
              formKey: formKey,
              urlController: urlController,
              onShortenUrl: () {},
              validator: (value) => null,
              isLoading: true,
            ),
          ),
        );

        await tester.pump();

        expect(
          find.byType(HomeHeaderComponent),
          matchesGoldenFile('goldens/home_header_loading_state.png'),
        );
      },
    );

    testWidgets(
      'given invalid url input '
      'when validation fails '
      'then returns error state golden',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildGoldenWrapper(
            HomeHeaderComponent(
              formKey: formKey,
              urlController: urlController,
              onShortenUrl: () {},
              validator: (value) => 'Invalid URL',
              failureErrorText: 'Invalid URL',
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(HomeHeaderComponent),
          matchesGoldenFile('goldens/home_header_error_state.png'),
        );
      },
    );
  });
}

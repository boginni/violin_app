import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:violin_design_system/violin_design_system.dart';

void main() {
  Widget buildGoldenWrapper(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            child: child,
          ),
        ),
      ),
    );
  }

  group('FaviconImage Goldens', () {
    testWidgets(
      'given a valid url '
      'when the widget renders '
      'then matches success golden file',
      (tester) async {
        const tProxyUrl = 'https://proxy.example.com';
        const tUrl = 'https://flutter.dev';

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            buildGoldenWrapper(
              const FaviconImage(
                proxyUrl: tProxyUrl,
                url: tUrl,
                size: 48.0,
              ),
            ),
          );
        });

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(FaviconImage),
          matchesGoldenFile('goldens/favicon_image_success.png'),
        );
      },
    );

    testWidgets(
      'given an invalid or empty url '
      'when the widget renders '
      'then matches failure golden file showing placeholder',
      (tester) async {
        const tProxyUrl = 'https://proxy.example.com';
        const tUrl = '';

        await tester.pumpWidget(
          buildGoldenWrapper(
            const FaviconImage(
              proxyUrl: tProxyUrl,
              url: tUrl,
              size: 48.0,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(FaviconImage),
          matchesGoldenFile('goldens/favicon_image_failure.png'),
        );
      },
    );
  });
}

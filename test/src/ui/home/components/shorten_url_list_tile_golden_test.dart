import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:violin_app/src/domain/dto/entities/shortened_url_entity.dart';
import 'package:violin_app/src/ui/home/components/shortened_url_list_tile.dart';

import '../../../../material_app_testing.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();

  late ShortenedUrlEntity tEntity;

  setUp(() {
    tEntity = const ShortenedUrlEntity(
      id: 1,
      url: 'https://sh.ort/abc',
      originalUrl: 'https://verylongurl.com/example/path/that/goes/on',
    );
  });

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

  group('ShortenedUrlListTile Goldens', () {
    testWidgets(
      'given a valid entity '
      'when the widget renders '
      'then matches golden file',
      (tester) async {
        tEntity = const ShortenedUrlEntity(
          id: 0,
          url: 'https://sh.ort/abc',
          originalUrl: 'https://example.com',
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            buildGoldenWrapper(
              ShortenedUrlListTile(
                entity: tEntity,
                onTap: () {},
              ),
            ),
          );

          await tester.pumpAndSettle();
        });

        await expectLater(
          find.byType(ShortenedUrlListTile),
          matchesGoldenFile('goldens/shortened_url_list_tile_valid.png'),
        );
      },
    );

    testWidgets(
      'given a invalid entity '
      'when the widget renders '
      'then matches golden file',
      (tester) async {
        tEntity = const ShortenedUrlEntity(
          id: 0,
          url: 'aaaaa',
          originalUrl: 'aaaaaa',
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            buildGoldenWrapper(
              ShortenedUrlListTile(
                entity: tEntity,
                onTap: () {},
              ),
            ),
          );

          await tester.pumpAndSettle();
        });

        await expectLater(
          find.byType(ShortenedUrlListTile),
          matchesGoldenFile('goldens/shortened_url_list_tile_invalid.png'),
        );
      },
    );
  });
}

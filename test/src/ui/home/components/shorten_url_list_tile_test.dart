import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/domain/dto/entities/shortened_url_entity.dart';
import 'package:violin_app/src/ui/home/components/shortened_url_list_tile.dart';

import '../../../../material_app_testing.dart';

void main() {
  late bool onTapCalled;
  late ShortenedUrlEntity tEntity;

  setUp(() {
    onTapCalled = false;

    tEntity = const ShortenedUrlEntity(
      id: 1,
      url: 'https://sh.ort/abc',
      originalUrl: 'https://verylongurl.com/example/path',
    );
  });

  Future<void> pumpListTile(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialAppTesting(
        builder: (BuildContext context) {
          return ShortenedUrlListTile(
            entity: tEntity,
            onTap: () => onTapCalled = true,
          );
        },
      ),
    );
  }

  group('ShortenedUrlListTile', () {
    testWidgets(
      'given valid entity '
      'when the widget renders '
      'then displays the shortened url, original url, and copy button',
      (tester) async {
        const tShortUrl = 'https://sh.ort/abc';
        const tOriginalUrl = 'https://verylongurl.com/example/path';

        tEntity = const ShortenedUrlEntity(
          id: 0,
          url: tShortUrl,
          originalUrl: tOriginalUrl,
        );

        await pumpListTile(tester);

        expect(find.text(tShortUrl), findsOneWidget);

        expect(find.text(tOriginalUrl), findsOneWidget);

        expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'given rendered widget '
      'when copy button is tapped '
      'then calls onTap callback',
      (tester) async {
        await pumpListTile(tester);

        await tester.tap(find.byIcon(Icons.copy_rounded));
        await tester.pumpAndSettle();

        expect(onTapCalled, isTrue);
      },
    );
  });
}

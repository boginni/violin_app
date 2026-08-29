import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/dto/entities/shortened_url_entity.dart';
import 'package:violin_app/src/domain/repositories/device_runtime_repository.dart';
import 'package:violin_app/src/domain/repositories/shorten_url_repository.dart';
import 'package:violin_app/src/ui/home/controllers/home_controller.dart';
import 'package:violin_app/src/ui/home/controllers/home_store.dart';
import 'package:violin_app/src/ui/home/controllers/shorten_history_store.dart';
import 'package:violin_app/src/ui/home/pages/home_page.dart';

import '../../../../material_app_testing.dart';

class MockDeviceRuntimeRepository extends Mock
    implements DeviceRuntimeRepository {}

class MockShortenUrlRepository extends Mock implements ShortenUrlRepository {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();

  Widget buildGoldenWrapper(Widget child) {
    return MaterialAppTesting(
      builder: (context) {
        return RepaintBoundary(
          child: child,
        );
      },
    );
  }

  group('HomeHeaderComponent Golden Tests', () {
    late final ShortenHistoryStore shortenHistoryStore;
    late final HomeStore homeStore;

    setUp(() {
      shortenHistoryStore = ShortenHistoryStore();
      homeStore = HomeStore();
    });

    testWidgets(
      'given the home page '
      'when has valid states '
      'then displays the success state',
      (WidgetTester tester) async {
        homeStore.state = HomeStoreState.success();
        shortenHistoryStore.state = ShortenHistoryStoreState.success([
          const ShortenedUrlEntity(
            id: 1,
            url: 'aaaaaaa',
            originalUrl: 'aaaaaaaa',
          ),
          const ShortenedUrlEntity(
            id: 1,
            url: 'bbbbb',
            originalUrl: 'bbbbbb',
          ),
          const ShortenedUrlEntity(
            id: 1,
            url: 'ccccc',
            originalUrl: 'ccccc',
          ),
        ]);

        await tester.pumpWidget(
          buildGoldenWrapper(
            HomePage(
              controller: HomeController(
                MockShortenUrlRepository(),
                MockDeviceRuntimeRepository(),
                store: homeStore,
                shortenHistoryStore: shortenHistoryStore,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(HomePage),
          matchesGoldenFile('goldens/home_page_success_state.png'),
        );
      },
    );
  });
}

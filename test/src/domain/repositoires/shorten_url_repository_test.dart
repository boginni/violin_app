import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/dto/entities/shortened_url_entity.dart';
import 'package:violin_app/src/domain/dto/params/shorten_url_params_entity.dart';
import 'package:violin_app/src/domain/repositories/shorten_url_repository.dart';

class MockShortenUrlRepository extends Mock implements ShortenUrlRepository {}

class FakeShortenUrlParamsEntity extends Fake
    implements ShortenUrlParamsEntity {}

class FakeShortenedUrlEntity extends Fake implements ShortenedUrlEntity {}

class FakeGetShortenedUrlHistoryParamsEntity extends Fake
    implements GetShortenedUrlHistoryParamsEntity {}

void main() {
  late MockShortenUrlRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeShortenUrlParamsEntity());
    registerFallbackValue(FakeGetShortenedUrlHistoryParamsEntity());
  });

  setUp(() {
    repository = MockShortenUrlRepository();
  });

  test(
    'given valid params '
    'when shortenUrl is called '
    'then returns shortened url entity',
    () async {
      final params = FakeShortenUrlParamsEntity();
      final expectedEntity = FakeShortenedUrlEntity();
      when(
        () => repository.shortenUrl(any()),
      ).thenAnswer((_) async => Result.success(expectedEntity));

      final result = await repository.shortenUrl(params);

      expect(result.isSuccess, true);
      expect(result.success, expectedEntity);
      verify(() => repository.shortenUrl(params)).called(1);
    },
  );

  test(
    'given valid id when getShortenedUrlById is called then returns corresponding entity',
    () async {
      const id = 123;
      final expectedEntity = FakeShortenedUrlEntity();
      when(
        () => repository.getShortenedUrlById(id),
      ).thenAnswer((_) async => Result.success(expectedEntity));

      final result = await repository.getShortenedUrlById(id);

      expect(result.isSuccess, true);
      expect(result.success, expectedEntity);
      verify(() => repository.getShortenedUrlById(id)).called(1);
    },
  );

  test(
    'given history params when getRecentlyShortenedUrls is called then returns list of entities',
    () async {
      final params = FakeGetShortenedUrlHistoryParamsEntity();
      final expectedList = [FakeShortenedUrlEntity(), FakeShortenedUrlEntity()];
      when(
        () => repository.getRecentlyShortenedUrls(any()),
      ).thenAnswer((_) async => Result.success(expectedList));

      final result = await repository.getRecentlyShortenedUrls(params);

      expect(result.isSuccess, true);
      expect(result.success, expectedList);
      expect(result.success.length, 2);
      verify(() => repository.getRecentlyShortenedUrls(params)).called(1);
    },
  );

  test(
    'given no params when getRecentlyShortenedUrls is called then returns full list of entities',
    () async {
      final expectedList = [FakeShortenedUrlEntity()];
      when(
        () => repository.getRecentlyShortenedUrls(),
      ).thenAnswer((_) async => Result.success(expectedList));

      final result = await repository.getRecentlyShortenedUrls();

      expect(result.isSuccess, true);
      expect(result.success, expectedList);
      verify(() => repository.getRecentlyShortenedUrls()).called(1);
    },
  );
}

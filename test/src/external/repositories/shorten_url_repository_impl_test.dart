import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter_test/flutter_test.dart' hide TestFailure;
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/dto/entities/shortened_url_entity.dart';
import 'package:violin_app/src/domain/dto/params/shorten_url_params_entity.dart';
import 'package:violin_app/src/external/datasources/shorten_url_datasource.dart';
import 'package:violin_app/src/external/repositories/shorten_url_repository_impl.dart';

class MockShortenUrlDatasource extends Mock implements ShortenUrlDatasource {}

class MockShortenedUrlEntity extends Mock implements ShortenedUrlEntity {}

class MockShortenUrlParamsEntity extends Mock
    implements ShortenUrlParamsEntity {}

class MockGetShortenedUrlHistoryParamsEntity extends Mock
    implements GetShortenedUrlHistoryParamsEntity {}

void main() {
  late MockShortenUrlDatasource mockDatasource;
  late ShortenUrlRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockShortenUrlDatasource();
    repository = ShortenUrlRepositoryImpl(mockDatasource);
  });

  group('getRecentlyShortenedUrls', () {
    test(
      'given valid params '
      'when getRecentlyShortenedUrls is called '
      'then returns list of shortened url entities',
      () async {
        final tParams = MockGetShortenedUrlHistoryParamsEntity();
        final tList = [MockShortenedUrlEntity()];
        when(
          () => mockDatasource.getShortenedUrlHistory(tParams),
        ).thenAnswer((_) async => tList);

        final result = await repository.getRecentlyShortenedUrls(tParams);

        expect(result.isSuccess, isTrue);
        expect(result.success, tList);
        verify(() => mockDatasource.getShortenedUrlHistory(tParams)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );

    test(
      'given a datasource exception '
      'when getRecentlyShortenedUrls is called '
      'then returns a failure Result',
      () async {
        final tParams = MockGetShortenedUrlHistoryParamsEntity();
        when(
          () => mockDatasource.getShortenedUrlHistory(tParams),
        ).thenThrow(const TestFailure());

        final result = await repository.getRecentlyShortenedUrls(tParams);

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
        verify(() => mockDatasource.getShortenedUrlHistory(tParams)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );
  });

  group('getShortenedUrlById', () {
    test(
      'given valid id '
      'when getShortenedUrlById is called '
      'then returns shortened url entity',
      () async {
        const tId = 1;
        final tEntity = MockShortenedUrlEntity();
        when(
          () => mockDatasource.getShortenedUrlById(tId),
        ).thenAnswer((_) async => tEntity);

        final result = await repository.getShortenedUrlById(tId);

        expect(result.isSuccess, isTrue);
        expect(result.success, tEntity);
        verify(() => mockDatasource.getShortenedUrlById(tId)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );

    test(
      'given a datasource exception '
      'when getShortenedUrlById is called '
      'then returns a failure Result',
      () async {
        const tId = 1;
        when(
          () => mockDatasource.getShortenedUrlById(tId),
        ).thenThrow(const TestFailure());

        final result = await repository.getShortenedUrlById(tId);

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
        verify(() => mockDatasource.getShortenedUrlById(tId)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );
  });

  group('shortenUrl', () {
    test(
      'given valid params '
      'when shortenUrl is called '
      'then returns shortened url entity',
      () async {
        final tParams = MockShortenUrlParamsEntity();
        final tEntity = MockShortenedUrlEntity();
        when(
          () => mockDatasource.shortenUrl(tParams),
        ).thenAnswer((_) async => tEntity);

        final result = await repository.shortenUrl(tParams);

        expect(result.isSuccess, isTrue);
        expect(result.success, tEntity);
        verify(() => mockDatasource.shortenUrl(tParams)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );

    test(
      'given a datasource exception '
      'when shortenUrl is called '
      'then returns a failure Result',
      () async {
        final tParams = MockShortenUrlParamsEntity();
        when(
          () => mockDatasource.shortenUrl(tParams),
        ).thenThrow(const TestFailure());

        final result = await repository.shortenUrl(tParams);

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
        verify(() => mockDatasource.shortenUrl(tParams)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );
  });
}

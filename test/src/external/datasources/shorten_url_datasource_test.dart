import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/dto/entities/shortened_url_entity.dart';
import 'package:violin_app/src/domain/dto/params/shorten_url_params_entity.dart';
import 'package:violin_app/src/external/datasources/shorten_url_datasource.dart';
import 'package:violin_app/src/external/provider/shorten_url_history_provider.dart';

class MockDio extends Mock implements Dio {}

class MockShortenUrlHistoryProvider extends Mock
    implements ShortenUrlHistoryProvider {}

class FakeShortenedUrlEntity extends Fake implements ShortenedUrlEntity {}

class FakeGetShortenedUrlHistoryParamsEntity extends Fake
    implements GetShortenedUrlHistoryParamsEntity {}

void main() {
  late MockDio mockDio;
  late MockShortenUrlHistoryProvider mockStorageProvider;
  late ShortenUrlDatasource datasource;

  setUp(() {
    mockDio = MockDio();
    mockStorageProvider = MockShortenUrlHistoryProvider();
    datasource = ShortenUrlDatasource(mockDio, mockStorageProvider);
  });

  setUpAll(() {
    registerFallbackValue(FakeGetShortenedUrlHistoryParamsEntity());
    registerFallbackValue(FakeShortenedUrlEntity());
  });

  group('shortenUrl', () {
    test(
      'given valid params '
      'when shortenUrl is called '
      'then returns shortened url entity',
      () async {
        const tParams = ShortenUrlParamsEntity(url: 'https://example.com');

        final tResponseData = {
          'id': 1,
          'alias': 'test_alias',
          'url': 'https://example.com',
        };

        final tResponse = Response(
          requestOptions: RequestOptions(path: '/alias'),
          data: tResponseData,
        );

        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => tResponse);
        when(() => mockStorageProvider.save(any())).thenAnswer((_) async {});

        final result = await datasource.shortenUrl(tParams);

        expect(result, isA<ShortenedUrlEntity>());
        verify(
          () => mockDio.post('/alias', data: any(named: 'data')),
        ).called(1);
        verify(() => mockStorageProvider.save(any())).called(1);
        verifyNoMoreInteractions(mockDio);
        verifyNoMoreInteractions(mockStorageProvider);
      },
    );

    test(
      'given an http error '
      'when shortenUrl is called '
      'then throws an exception',
      () async {
        const tParams = ShortenUrlParamsEntity(url: 'https://example.com');

        final tException = Exception('Http Error');

        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(tException);

        expect(
          () => datasource.shortenUrl(tParams),
          throwsA(isA<Exception>()),
        );
        verify(
          () => mockDio.post('/alias', data: any(named: 'data')),
        ).called(1);
        verifyZeroInteractions(mockStorageProvider);
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

        final tResponseData = {
          'id': tId,
          'alias': 'test_alias',
          'url': 'https://example.com',
        };

        final tResponse = Response(
          requestOptions: RequestOptions(path: '/alias/$tId'),
          data: tResponseData,
        );

        when(() => mockDio.get(any())).thenAnswer((_) async => tResponse);

        final result = await datasource.getShortenedUrlById(tId);

        expect(result, isA<ShortenedUrlEntity>());
        verify(() => mockDio.get('/alias/$tId')).called(1);
        verifyNoMoreInteractions(mockDio);
      },
    );
  });

  group('getShortenedUrlHistory', () {
    test(
      'given params are provided '
      'when getShortenedUrlHistory is called '
      'then returns list of shortened url entities from storage',
      () async {
        const tParams = GetShortenedUrlHistoryParamsEntity();

        final tList = [
          const ShortenedUrlEntity(
            url: 'https://test.com',
            id: 1,
            originalUrl: 'https://test.com',
          ),
        ];

        when(
          () => mockStorageProvider.getHistory(any()),
        ).thenAnswer((_) async => tList);

        final result = await datasource.getShortenedUrlHistory(tParams);

        expect(result, tList);
        verify(() => mockStorageProvider.getHistory(tParams)).called(1);
        verifyNoMoreInteractions(mockStorageProvider);
      },
    );

    test(
      'given no params are provided '
      'when getShortenedUrlHistory is called '
      'then returns list using default params',
      () async {
        final tList = [
          const ShortenedUrlEntity(
            url: 'https://test.com',
            id: 1,
            originalUrl: 'https://test.com',
          ),
        ];

        when(
          () => mockStorageProvider.getHistory(any()),
        ).thenAnswer((_) async => tList);

        final result = await datasource.getShortenedUrlHistory();

        expect(result, tList);
        verify(() => mockStorageProvider.getHistory(any())).called(1);
        verifyNoMoreInteractions(mockStorageProvider);
      },
    );
  });
}

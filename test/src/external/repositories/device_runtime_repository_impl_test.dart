import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter_test/flutter_test.dart' hide TestFailure;
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/external/datasources/device_runtime_datasource.dart';
import 'package:violin_app/src/external/repositories/device_runtime_repository_impl.dart';

class MockDeviceRuntimeDatasource extends Mock
    implements DeviceRuntimeDatasource {}

void main() {
  late MockDeviceRuntimeDatasource mockDatasource;
  late DeviceRuntimeRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockDeviceRuntimeDatasource();
    repository = DeviceRuntimeRepositoryImpl(mockDatasource);
  });

  group('copyToClipboard', () {
    test(
      'given valid text '
      'when copyToClipboard is called '
      'then returns a successful Result',
      () async {
        const tText = 'test string';
        when(
          () => mockDatasource.copyToClipboard(tText),
        ).thenAnswer((_) async {});

        final result = await repository.copyToClipboard(tText);

        expect(result.isSuccess, isTrue);
        verify(() => mockDatasource.copyToClipboard(tText)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );

    test(
      'given a datasource exception '
      'when copyToClipboard is called '
      'then returns a failure Result',
      () async {
        const tText = 'test string';
        when(
          () => mockDatasource.copyToClipboard(tText),
        ).thenThrow(const TestFailure());

        final result = await repository.copyToClipboard(tText);

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
        verify(() => mockDatasource.copyToClipboard(tText)).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );
  });

  group('getClipboardData', () {
    test(
      'given clipboard has text '
      'when getClipboardData is called '
      'then returns successful Result with clipboard string',
      () async {
        const tClipboardData = 'copied text';
        when(
          () => mockDatasource.getClipboardData(),
        ).thenAnswer((_) async => tClipboardData);

        final result = await repository.getClipboardData();

        expect(result.isSuccess, isTrue);
        expect(result.success, tClipboardData);
        verify(() => mockDatasource.getClipboardData()).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );

    test(
      'given a datasource exception '
      'when getClipboardData is called '
      'then returns a failure Result',
      () async {
        when(
          () => mockDatasource.getClipboardData(),
        ).thenThrow(const TestFailure());

        final result = await repository.getClipboardData();

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
        verify(() => mockDatasource.getClipboardData()).called(1);
        verifyNoMoreInteractions(mockDatasource);
      },
    );
  });
}

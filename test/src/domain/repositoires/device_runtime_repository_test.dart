import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter_test/flutter_test.dart' hide TestFailure;
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/repositories/device_runtime_repository.dart';

class MockDeviceRuntimeRepository extends Mock
    implements DeviceRuntimeRepository {}

void main() {
  late MockDeviceRuntimeRepository repository;

  setUp(() {
    repository = MockDeviceRuntimeRepository();
  });

  test(
    'given text string '
    'when copyToClipboard is called '
    'then returns success result',
    () async {
      const textToCopy = 'test clipboard';
      when(
        () => repository.copyToClipboard(textToCopy),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await repository.copyToClipboard(textToCopy);

      expect(result.isSuccess, true);
      verify(() => repository.copyToClipboard(textToCopy)).called(1);
    },
  );

  test(
    'given clipboard contains data '
    'when getClipboardData is called '
    'then returns data string',
    () async {
      const clipboardText = 'copied text';

      when(
        () => repository.getClipboardData(),
      ).thenAnswer((_) async => const Result.success(clipboardText));

      final result = await repository.getClipboardData();

      expect(result.isSuccess, true);
      expect(result.success, clipboardText);
      verify(() => repository.getClipboardData()).called(1);
    },
  );

  test(
    'given clipboard access fails '
    'when getClipboardData is called '
    'then returns failure result',
    () async {
      const error = TestFailure();

      when(
        () => repository.getClipboardData(),
      ).thenAnswer((_) async => const Result.failure(error));

      final result = await repository.getClipboardData();

      expect(result.isFailure, true);
      expect(result.failure, error);
      verify(() => repository.getClipboardData()).called(1);
    },
  );
}

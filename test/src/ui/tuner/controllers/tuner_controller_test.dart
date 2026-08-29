import 'dart:async';

import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter_test/flutter_test.dart' hide TestFailure;
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/dto/entities/detected_note_entity.dart';
import 'package:violin_app/src/domain/dto/entities/pitch_class.dart';
import 'package:violin_app/src/domain/dto/entities/violin_open_string.dart';
import 'package:violin_app/src/domain/repositories/tuner_repository.dart';
import 'package:violin_app/src/ui/tuner/controllers/tuner_controller.dart';
import 'package:violin_app/src/ui/tuner/controllers/tuner_store.dart';

class MockTunerRepository extends Mock implements TunerRepository {}

void main() {
  late MockTunerRepository repository;
  late TunerStore store;
  late TunerController controller;

  setUp(() {
    repository = MockTunerRepository();
    store = TunerStore();
    controller = TunerController(repository, store: store);
  });

  group('start', () {
    test(
      'given start is called '
      'when the repository has not resolved yet '
      'then the store immediately shows listening with no note',
      () {
        when(
          () => repository.startListening(),
        ).thenAnswer((_) => Completer<Result<Stream<DetectedNoteEntity?>>>().future);

        unawaited(controller.start());

        expect(store.state, isA<TunerStoreListeningState>());
        expect((store.state as TunerStoreListeningState).note, isNull);
      },
    );

    test(
      'given the repository starts listening successfully '
      'when start is called '
      'then the store ends up listening with the detected note',
      () async {
        const note = DetectedNoteEntity(
          pitchClass: PitchClass.a,
          octave: 4,
          frequency: 440,
          expectedFrequency: 440,
          centsOffset: 0,
          closestOpenString: ViolinOpenString.a4,
        );

        when(() => repository.startListening()).thenAnswer(
          (_) async => Result.success(Stream.fromIterable([note])),
        );

        await controller.start();
        await Future.delayed(Duration.zero);

        expect(store.state, isA<TunerStoreListeningState>());
        expect((store.state as TunerStoreListeningState).note, note);
        verify(() => repository.startListening()).called(1);
      },
    );

    test(
      'given the store is already listening '
      'when start is called again '
      'then it does not start a new recording session',
      () async {
        store.state = TunerStoreState.listening(null);

        await controller.start();

        verifyNever(() => repository.startListening());
      },
    );

    test(
      'given the repository fails with a non-fatal failure '
      'when start is called '
      'then the store shows a failure state without rethrowing',
      () async {
        const failure = TestFailure();
        when(
          () => repository.startListening(),
        ).thenAnswer((_) async => const Result.failure(failure));

        await controller.start();

        expect(store.state, isA<TunerStoreFailureState>());
        expect((store.state as TunerStoreFailureState).failure, failure);
      },
    );

    test(
      'given the repository fails with a fatal failure '
      'when start is called '
      'then the store shows a failure state and the failure is rethrown',
      () async {
        const failure = UnknownFailure('boom', StackTrace.empty);
        when(
          () => repository.startListening(),
        ).thenAnswer((_) async => const Result.failure(failure));

        await expectLater(controller.start(), throwsA(failure));
        expect(store.state, isA<TunerStoreFailureState>());
      },
    );
  });

  group('stop', () {
    test(
      'given an active listening session '
      'when stop is called '
      'then the store returns to idle',
      () async {
        store.state = TunerStoreState.listening(null);
        when(
          () => repository.stopListening(),
        ).thenAnswer((_) async => const Result.success(null));

        await controller.stop();

        expect(store.state, isA<TunerStoreIdleState>());
        verify(() => repository.stopListening()).called(1);
      },
    );

    test(
      'given the repository fails to stop with a fatal failure '
      'when stop is called '
      'then the store returns to idle and the failure is rethrown',
      () async {
        const failure = UnknownFailure('boom', StackTrace.empty);
        when(
          () => repository.stopListening(),
        ).thenAnswer((_) async => Result.failure(failure));

        await expectLater(controller.stop(), throwsA(failure));
        expect(store.state, isA<TunerStoreIdleState>());
      },
    );
  });
}

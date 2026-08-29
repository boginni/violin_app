import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter_test/flutter_test.dart' hide TestFailure;
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/dto/entities/detected_note_entity.dart';
import 'package:violin_app/src/domain/dto/entities/pitch_class.dart';
import 'package:violin_app/src/domain/dto/entities/violin_open_string.dart';
import 'package:violin_app/src/domain/repositories/tuner_repository.dart';

class MockTunerRepository extends Mock implements TunerRepository {}

void main() {
  late MockTunerRepository repository;

  setUp(() {
    repository = MockTunerRepository();
  });

  test(
    'given microphone access is granted '
    'when startListening is called '
    'then returns a stream of detected notes',
    () async {
      const note = DetectedNoteEntity(
        pitchClass: PitchClass.a,
        octave: 4,
        frequency: 440,
        expectedFrequency: 440,
        centsOffset: 0,
        closestOpenString: ViolinOpenString.a4,
      );

      when(
        () => repository.startListening(),
      ).thenAnswer((_) async => Result.success(Stream.value(note)));

      final result = await repository.startListening();

      expect(result.isSuccess, true);
      await expectLater(result.success, emits(note));
      verify(() => repository.startListening()).called(1);
    },
  );

  test(
    'given microphone access is denied '
    'when startListening is called '
    'then returns a failure result',
    () async {
      const error = TestFailure();

      when(
        () => repository.startListening(),
      ).thenAnswer((_) async => const Result.failure(error));

      final result = await repository.startListening();

      expect(result.isFailure, true);
      expect(result.failure, error);
      verify(() => repository.startListening()).called(1);
    },
  );

  test(
    'given an active recording '
    'when stopListening is called '
    'then returns a success result',
    () async {
      when(
        () => repository.stopListening(),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await repository.stopListening();

      expect(result.isSuccess, true);
      verify(() => repository.stopListening()).called(1);
    },
  );

  test(
    'given no listening session is active '
    'when getCurrentStream is called '
    'then returns a successful result wrapping null',
    () {
      when(
        () => repository.getCurrentStream(),
      ).thenReturn(const Result.success());

      final result = repository.getCurrentStream();

      expect(result.isSuccess, true);
      expect(result.success, isNull);
    },
  );

  test(
    'given a listening session is active '
    'when getCurrentStream is called '
    'then returns a successful result wrapping the stream from the last '
    'startListening call',
    () {
      const note = DetectedNoteEntity(
        pitchClass: PitchClass.a,
        octave: 4,
        frequency: 440,
        expectedFrequency: 440,
        centsOffset: 0,
        closestOpenString: ViolinOpenString.a4,
      );
      final noteStream = Stream<DetectedNoteEntity?>.value(note);

      when(
        () => repository.getCurrentStream(),
      ).thenReturn(Result.success(noteStream));

      final result = repository.getCurrentStream();

      expect(result.isSuccess, true);
      expect(result.success, noteStream);
    },
  );
}

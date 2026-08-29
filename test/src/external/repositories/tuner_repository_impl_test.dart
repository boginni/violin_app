import 'dart:typed_data';

import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter_test/flutter_test.dart' hide TestFailure;
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/domain/dto/entities/detected_note_entity.dart';
import 'package:violin_app/src/domain/dto/entities/pitch_class.dart';
import 'package:violin_app/src/domain/dto/entities/violin_open_string.dart';
import 'package:violin_app/src/external/datasources/microphone_datasource.dart';
import 'package:violin_app/src/external/repositories/tuner_repository_impl.dart';
import 'package:violin_app/src/external/services/pitch_analysis_transformer.dart';

class MockMicrophoneDatasource extends Mock implements MicrophoneDatasource {}

class MockPitchAnalysisTransformer extends Mock
    implements PitchAnalysisTransformer {}

void main() {
  late MockMicrophoneDatasource mockDatasource;
  late MockPitchAnalysisTransformer mockTransformer;
  late TunerRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockMicrophoneDatasource();
    mockTransformer = MockPitchAnalysisTransformer();
    repository = TunerRepositoryImpl(mockDatasource, mockTransformer);
  });

  setUpAll(() {
    registerFallbackValue(const Stream<Uint8List>.empty());
  });

  group('startListening', () {
    test(
      'given the datasource starts streaming '
      'when startListening is called '
      'then returns a successful Result wrapping the analyzed note stream',
      () async {
        final pcmStream = Stream<Uint8List>.value(Uint8List(0));
        const note = DetectedNoteEntity(
          pitchClass: PitchClass.a,
          octave: 4,
          frequency: 440,
          expectedFrequency: 440,
          centsOffset: 0,
          closestOpenString: ViolinOpenString.a4,
        );

        when(
          () => mockDatasource.startStream(),
        ).thenAnswer((_) async => pcmStream);
        when(
          () => mockTransformer.bind(pcmStream),
        ).thenAnswer((_) => Stream.value(note));

        final result = await repository.startListening();

        expect(result.isSuccess, isTrue);
        await expectLater(result.success, emits(note));
        verify(() => mockDatasource.startStream()).called(1);
        verify(() => mockTransformer.bind(pcmStream)).called(1);
      },
    );

    test(
      'given the datasource throws '
      'when startListening is called '
      'then returns a failure Result',
      () async {
        when(() => mockDatasource.startStream()).thenThrow(const TestFailure());

        final result = await repository.startListening();

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
        verifyNever(() => mockTransformer.bind(any()));
      },
    );
  });

  group('stopListening', () {
    test(
      'given the datasource stops successfully '
      'when stopListening is called '
      'then returns a successful Result',
      () async {
        when(() => mockDatasource.stopStream()).thenAnswer((_) async {});

        final result = await repository.stopListening();

        expect(result.isSuccess, isTrue);
        verify(() => mockDatasource.stopStream()).called(1);
      },
    );

    test(
      'given the datasource throws '
      'when stopListening is called '
      'then returns a failure Result',
      () async {
        when(() => mockDatasource.stopStream()).thenThrow(const TestFailure());

        final result = await repository.stopListening();

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
      },
    );
  });

  group('getCurrentStream', () {
    test(
      'given the datasource has no active stream '
      'when getCurrentStream is called '
      'then returns a successful result wrapping null without analyzing '
      'anything',
      () {
        when(() => mockDatasource.getCurrentStream()).thenReturn(null);

        final result = repository.getCurrentStream();

        expect(result.isSuccess, isTrue);
        expect(result.success, isNull);
        verifyNever(() => mockTransformer.bind(any()));
      },
    );

    test(
      'given the datasource has an active stream '
      'when getCurrentStream is called '
      'then returns a successful result wrapping the datasource stream '
      'analyzed into notes',
      () {
        final pcmStream = Stream<Uint8List>.value(Uint8List(0));
        const noteStream = Stream<DetectedNoteEntity?>.empty();

        when(
          () => mockDatasource.getCurrentStream(),
        ).thenAnswer((_) => pcmStream);
        when(
          () => mockTransformer.bind(pcmStream),
        ).thenAnswer((_) => noteStream);

        final result = repository.getCurrentStream();

        expect(result.isSuccess, isTrue);
        expect(result.success, noteStream);
        verify(() => mockTransformer.bind(pcmStream)).called(1);
      },
    );

    test(
      'given the datasource throws '
      'when getCurrentStream is called '
      'then returns a failure result',
      () {
        when(
          () => mockDatasource.getCurrentStream(),
        ).thenThrow(const TestFailure());

        final result = repository.getCurrentStream();

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<TestFailure>());
      },
    );
  });
}

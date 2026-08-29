import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/external/architecture/microphone_failures.dart';
import 'package:violin_app/src/external/datasources/microphone_datasource.dart';
import 'package:violin_app/src/external/datasources/microphone_recorder.dart';
import 'package:record/record.dart';

class MockMicrophoneRecorder extends Mock implements MicrophoneRecorder {}

void main() {
  late MockMicrophoneRecorder mockRecorder;
  late MicrophoneDatasource datasource;

  setUpAll(() {
    registerFallbackValue(const RecordConfig());
  });

  setUp(() {
    mockRecorder = MockMicrophoneRecorder();
    datasource = MicrophoneDatasource(mockRecorder);
  });

  group('startStream', () {
    test(
      'given microphone permission is granted '
      'when startStream is called '
      'then starts a pcm16 mono stream at the expected sample rate',
      () async {
        final pcmStream = Stream<Uint8List>.value(Uint8List(0));

        when(() => mockRecorder.hasPermission()).thenAnswer((_) async => true);
        when(
          () => mockRecorder.start(any()),
        ).thenAnswer((_) async => pcmStream);

        final result = await datasource.startStream();

        expect(result, pcmStream);

        final config =
            verify(() => mockRecorder.start(captureAny())).captured.single
                as RecordConfig;
        expect(config.encoder, AudioEncoder.pcm16bits);
        expect(config.sampleRate, MicrophoneDatasource.sampleRate);
        expect(config.numChannels, 1);
      },
    );

    test(
      'given microphone permission is denied '
      'when startStream is called '
      'then throws MicrophonePermissionDeniedFailure',
      () async {
        when(
          () => mockRecorder.hasPermission(),
        ).thenAnswer((_) async => false);

        expect(
          () => datasource.startStream(),
          throwsA(isA<MicrophonePermissionDeniedFailure>()),
        );
        verifyNever(() => mockRecorder.start(any()));
      },
    );
  });

  group('stopStream', () {
    test(
      'given an active recording '
      'when stopStream is called '
      'then stops the recorder',
      () async {
        when(() => mockRecorder.stop()).thenAnswer((_) async {});

        await datasource.stopStream();

        verify(() => mockRecorder.stop()).called(1);
      },
    );
  });

  group('getCurrentStream', () {
    test(
      'given no recording is active '
      'when getCurrentStream is called '
      'then delegates to the wrapper and returns null',
      () {
        when(() => mockRecorder.getCurrentStream()).thenReturn(null);

        expect(datasource.getCurrentStream(), isNull);
      },
    );

    test(
      'given a recording is active '
      'when getCurrentStream is called '
      'then delegates to the wrapper and returns its current stream',
      () {
        final pcmStream = Stream<Uint8List>.value(Uint8List(0));

        when(
          () => mockRecorder.getCurrentStream(),
        ).thenAnswer((_) => pcmStream);

        expect(datasource.getCurrentStream(), pcmStream);
      },
    );
  });
}

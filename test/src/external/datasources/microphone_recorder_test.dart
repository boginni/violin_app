import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:violin_app/src/external/datasources/microphone_recorder.dart';
import 'package:record/record.dart';

class MockAudioRecorder extends Mock implements AudioRecorder {}

void main() {
  late MockAudioRecorder mockAudioRecorder;
  late MicrophoneRecorder recorder;

  setUpAll(() {
    registerFallbackValue(const RecordConfig());
  });

  setUp(() {
    mockAudioRecorder = MockAudioRecorder();
    recorder = MicrophoneRecorder(mockAudioRecorder);
  });

  group('getCurrentStream', () {
    test(
      'given no recording has been started '
      'when getCurrentStream is called '
      'then returns null',
      () {
        expect(recorder.getCurrentStream(), isNull);
      },
    );

    test(
      'given a recording was started '
      'when getCurrentStream is called '
      'then returns the stream from the last start call',
      () async {
        final pcmStream = Stream<Uint8List>.value(Uint8List(0));

        when(
          () => mockAudioRecorder.startStream(any()),
        ).thenAnswer((_) async => pcmStream);

        await recorder.start(const RecordConfig());

        expect(recorder.getCurrentStream(), pcmStream);
      },
    );

    test(
      'given a recording was stopped '
      'when getCurrentStream is called '
      'then returns null',
      () async {
        final pcmStream = Stream<Uint8List>.value(Uint8List(0));

        when(
          () => mockAudioRecorder.startStream(any()),
        ).thenAnswer((_) async => pcmStream);
        when(() => mockAudioRecorder.stop()).thenAnswer((_) async => null);

        await recorder.start(const RecordConfig());
        await recorder.stop();

        expect(recorder.getCurrentStream(), isNull);
      },
    );
  });

  group('hasPermission', () {
    test(
      'when hasPermission is called '
      'then delegates to the wrapped AudioRecorder',
      () async {
        when(
          () => mockAudioRecorder.hasPermission(),
        ).thenAnswer((_) async => true);

        final result = await recorder.hasPermission();

        expect(result, isTrue);
        verify(() => mockAudioRecorder.hasPermission()).called(1);
      },
    );
  });

  group('start', () {
    test(
      'when start is called '
      'then forwards the given config to the wrapped AudioRecorder',
      () async {
        final pcmStream = Stream<Uint8List>.value(Uint8List(0));
        const config = RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        );

        when(
          () => mockAudioRecorder.startStream(any()),
        ).thenAnswer((_) async => pcmStream);

        final result = await recorder.start(config);

        expect(result, pcmStream);
        verify(() => mockAudioRecorder.startStream(config)).called(1);
      },
    );
  });

  group('stop', () {
    test(
      'when stop is called '
      'then stops the wrapped AudioRecorder',
      () async {
        when(() => mockAudioRecorder.stop()).thenAnswer((_) async => null);

        await recorder.stop();

        verify(() => mockAudioRecorder.stop()).called(1);
      },
    );
  });
}

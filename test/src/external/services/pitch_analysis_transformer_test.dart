import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/domain/dto/entities/pitch_class.dart';
import 'package:violin_app/src/external/services/pitch_analysis_transformer.dart';
import 'package:violin_app/src/external/services/pitch_class_mapper.dart';
import 'package:violin_app/src/external/services/pitch_detector.dart';
import 'package:violin_app/src/external/services/violin_open_string_locator.dart';

Int16List _generateSineWave(double frequency, int sampleRate, int length) {
  final samples = Int16List(length);

  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    samples[i] = (0.5 * 32767 * sin(2 * pi * frequency * t)).round();
  }

  return samples;
}

Uint8List _encodePcm16(Int16List samples) {
  final bytes = ByteData(samples.length * 2);

  for (var i = 0; i < samples.length; i++) {
    bytes.setInt16(i * 2, samples[i], Endian.little);
  }

  return bytes.buffer.asUint8List();
}

void main() {
  const transformer = PitchAnalysisTransformer(
    PitchDetector(),
    PitchClassMapper(),
    ViolinOpenStringLocator(),
  );

  test(
    'given a pcm16 byte stream carrying a 440Hz tone '
    'when the stream is transformed '
    'then emits a detected A4 note',
    () async {
      final samples = _generateSineWave(
        440,
        transformer.sampleRate,
        transformer.windowSize,
      );
      final bytes = _encodePcm16(samples);

      final notes = await Stream.value(bytes).transform(transformer).toList();

      expect(notes, hasLength(1));
      expect(notes.single, isNotNull);
      expect(notes.single!.pitchClass, PitchClass.a);
      expect(notes.single!.octave, 4);
    },
  );

  test(
    'given a pcm16 byte stream carrying silence '
    'when the stream is transformed '
    'then emits null for the analyzed window',
    () async {
      final bytes = Uint8List(transformer.windowSize * 2);

      final notes = await Stream.value(bytes).transform(transformer).toList();

      expect(notes, [null]);
    },
  );

  test(
    'given pcm16 bytes split across multiple chunks '
    'when the stream is transformed '
    'then still buffers them into a full window before analyzing',
    () async {
      final samples = _generateSineWave(
        440,
        transformer.sampleRate,
        transformer.windowSize,
      );
      final bytes = _encodePcm16(samples);
      final half = bytes.length ~/ 2;

      final notes = await Stream.fromIterable([
        bytes.sublist(0, half),
        bytes.sublist(half),
      ]).transform(transformer).toList();

      expect(notes, hasLength(1));
      expect(notes.single?.pitchClass, PitchClass.a);
      expect(notes.single?.octave, 4);
    },
  );
}

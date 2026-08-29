import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/external/services/pitch_detector.dart';

Int16List generateSineWave(
  double frequency,
  int sampleRate,
  int length, {
  double amplitude = 0.5,
}) {
  final samples = Int16List(length);

  for (var i = 0; i < length; i++) {
    final t = i / sampleRate;
    samples[i] = (amplitude * 32767 * sin(2 * pi * frequency * t)).round();
  }

  return samples;
}

void main() {
  const detector = PitchDetector();
  const sampleRate = 44100;
  const windowSize = 4096;

  test(
    'given a 440Hz sine wave '
    'when detectFrequency is called '
    'then returns a frequency close to 440Hz',
    () {
      final samples = generateSineWave(440, sampleRate, windowSize);

      final frequency = detector.detectFrequency(samples, sampleRate);

      expect(frequency, isNotNull);
      expect(frequency, closeTo(440, 5));
    },
  );

  test(
    'given a 196Hz sine wave (violin open G string) '
    'when detectFrequency is called '
    'then returns a frequency close to 196Hz',
    () {
      final samples = generateSineWave(196, sampleRate, windowSize);

      final frequency = detector.detectFrequency(samples, sampleRate);

      expect(frequency, isNotNull);
      expect(frequency, closeTo(196, 5));
    },
  );

  test(
    'given silence '
    'when detectFrequency is called '
    'then returns null',
    () {
      final samples = Int16List(windowSize);

      final frequency = detector.detectFrequency(samples, sampleRate);

      expect(frequency, isNull);
    },
  );

  test(
    'given an empty sample buffer '
    'when detectFrequency is called '
    'then returns null',
    () {
      final frequency = detector.detectFrequency(Int16List(0), sampleRate);

      expect(frequency, isNull);
    },
  );
}

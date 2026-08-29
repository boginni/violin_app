import 'dart:math';

import '../../domain/dto/entities/pitch_class.dart';

class MappedPitch {
  const MappedPitch({
    required this.pitchClass,
    required this.octave,
    required this.expectedFrequency,
    required this.centsOffset,
  });

  final PitchClass pitchClass;
  final int octave;
  final double expectedFrequency;
  final double centsOffset;
}

/// Maps a measured frequency to the nearest pitch class and octave on the
/// equal-tempered chromatic scale (A4 = 440Hz). Not specific to any
/// instrument — unlike a lookup table of note names, this only ever
/// produces the abstract [PitchClass] value.
class PitchClassMapper {
  const PitchClassMapper();

  static const _a4Frequency = 440.0;
  static const _a4MidiNumber = 69;

  MappedPitch map(double frequency) {
    final pitchClassCount = PitchClass.values.length;
    final semitonesFromA4 = (12 * (log(frequency / _a4Frequency) / ln2))
        .round();
    final expectedFrequency = _a4Frequency * pow(2, semitonesFromA4 / 12);
    final centsOffset = 1200 * (log(frequency / expectedFrequency) / ln2);

    final midiNumber = _a4MidiNumber + semitonesFromA4;
    final pitchClass = PitchClass.values[midiNumber % pitchClassCount];
    final octave = (midiNumber ~/ pitchClassCount) - 1;

    return MappedPitch(
      pitchClass: pitchClass,
      octave: octave,
      expectedFrequency: expectedFrequency,
      centsOffset: centsOffset,
    );
  }
}

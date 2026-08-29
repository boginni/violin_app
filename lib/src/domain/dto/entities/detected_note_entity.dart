import 'pitch_class.dart';
import 'violin_open_string.dart';

class DetectedNoteEntity {
  const DetectedNoteEntity({
    required this.pitchClass,
    required this.octave,
    required this.frequency,
    required this.expectedFrequency,
    required this.centsOffset,
    required this.closestOpenString,
  });

  /// The detected note's pitch class on the chromatic scale — an abstract
  /// value with no inherent display name; naming it (e.g. Western letters
  /// vs. solfège) is a presentation-layer concern, not a domain one.
  final PitchClass pitchClass;

  /// The octave number, using scientific pitch notation (A4 = 440Hz).
  final int octave;

  /// The frequency measured from the microphone, in Hz.
  final double frequency;

  /// The exact frequency of [pitchClass]/[octave] on the equal-tempered
  /// scale (A4 = 440Hz), in Hz.
  final double expectedFrequency;

  /// How far [frequency] is from [expectedFrequency], in cents.
  /// Negative means flat, positive means sharp.
  final double centsOffset;

  /// The nearest violin open string, or `null` when [frequency] isn't
  /// close enough to any open string.
  final ViolinOpenString? closestOpenString;

  bool get isInTune => centsOffset.abs() <= 5;
}

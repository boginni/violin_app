import 'pitch_class.dart';

/// The four open strings of a violin, tuned in perfect fifths under
/// standard A440 tuning.
enum ViolinOpenString {
  g3(pitchClass: PitchClass.g, octave: 3, frequency: 196.00),
  d4(pitchClass: PitchClass.d, octave: 4, frequency: 293.66),
  a4(pitchClass: PitchClass.a, octave: 4, frequency: 440.00),
  e5(pitchClass: PitchClass.e, octave: 5, frequency: 659.25);

  const ViolinOpenString({
    required this.pitchClass,
    required this.octave,
    required this.frequency,
  });

  final PitchClass pitchClass;

  final int octave;

  /// Reference frequency at standard A440 tuning, in Hz.
  final double frequency;
}

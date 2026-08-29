import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/domain/dto/entities/pitch_class.dart';
import 'package:violin_app/src/external/services/pitch_class_mapper.dart';

void main() {
  const mapper = PitchClassMapper();

  test(
    'given exactly 440Hz '
    'when map is called '
    'then returns pitch class A, octave 4, with no cents offset',
    () {
      final pitch = mapper.map(440);

      expect(pitch.pitchClass, PitchClass.a);
      expect(pitch.octave, 4);
      expect(pitch.expectedFrequency, closeTo(440, 0.01));
      expect(pitch.centsOffset, closeTo(0, 0.01));
    },
  );

  test(
    'given exactly 196Hz '
    'when map is called '
    'then returns pitch class G, octave 3',
    () {
      final pitch = mapper.map(196);

      expect(pitch.pitchClass, PitchClass.g);
      expect(pitch.octave, 3);
    },
  );

  test(
    'given a frequency slightly above A4 '
    'when map is called '
    'then returns pitch class A, octave 4, with a positive cents offset',
    () {
      final pitch = mapper.map(445);

      expect(pitch.pitchClass, PitchClass.a);
      expect(pitch.octave, 4);
      expect(pitch.centsOffset, greaterThan(0));
    },
  );

  test(
    'given a frequency slightly below A4 '
    'when map is called '
    'then returns a negative cents offset',
    () {
      final pitch = mapper.map(435);

      expect(pitch.centsOffset, lessThan(0));
    },
  );
}

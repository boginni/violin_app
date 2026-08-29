import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/domain/dto/entities/detected_note_entity.dart';
import 'package:violin_app/src/domain/dto/entities/pitch_class.dart';
import 'package:violin_app/src/domain/dto/entities/violin_open_string.dart';
import 'package:violin_app/src/ui/tuner/components/tuner_listening_component.dart';

import '../../../../material_app_testing.dart';

void main() {
  testWidgets(
    'given no note has been detected yet '
    'when rendered '
    'then shows the listening hint',
    (tester) async {
      await tester.pumpWidget(
        MaterialAppTesting(
          builder: (context) => TunerListeningComponent(
            note: null,
            onStop: () {},
          ),
        ),
      );

      expect(find.text('Play a note on your violin'), findsOneWidget);
    },
  );

  testWidgets(
    'given an in-tune note was detected '
    'when rendered '
    'then shows the note name, frequency and in-tune status',
    (tester) async {
      const note = DetectedNoteEntity(
        pitchClass: PitchClass.a,
        octave: 4,
        frequency: 440,
        expectedFrequency: 440,
        centsOffset: 0,
        closestOpenString: ViolinOpenString.a4,
      );

      var stopTapped = false;

      await tester.pumpWidget(
        MaterialAppTesting(
          builder: (context) => TunerListeningComponent(
            note: note,
            onStop: () => stopTapped = true,
          ),
        ),
      );

      expect(find.text('A4'), findsOneWidget);
      expect(find.text('440.0 Hz'), findsOneWidget);
      expect(find.text('In tune'), findsOneWidget);
      expect(find.text('Closest string: A4'), findsOneWidget);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(stopTapped, isTrue);
    },
  );

  testWidgets(
    'given a sharp note was detected '
    'when rendered '
    'then shows the too sharp status',
    (tester) async {
      const note = DetectedNoteEntity(
        pitchClass: PitchClass.a,
        octave: 4,
        frequency: 445,
        expectedFrequency: 440,
        centsOffset: 19.6,
        closestOpenString: ViolinOpenString.a4,
      );

      await tester.pumpWidget(
        MaterialAppTesting(
          builder: (context) => TunerListeningComponent(
            note: note,
            onStop: () {},
          ),
        ),
      );

      expect(find.text('Too sharp'), findsOneWidget);
    },
  );
}

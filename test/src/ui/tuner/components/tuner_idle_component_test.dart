import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/ui/tuner/components/tuner_idle_component.dart';

import '../../../../material_app_testing.dart';

void main() {
  testWidgets(
    'given the tuner is idle '
    'when rendered '
    'then shows the start listening button and invokes onStart when tapped',
    (tester) async {
      var startTapped = false;

      await tester.pumpWidget(
        MaterialAppTesting(
          builder: (context) => TunerIdleComponent(
            onStart: () => startTapped = true,
          ),
        ),
      );

      expect(find.text('Start listening'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(startTapped, isTrue);
    },
  );
}

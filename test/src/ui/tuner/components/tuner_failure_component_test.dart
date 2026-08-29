import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/ui/tuner/components/tuner_failure_component.dart';

import '../../../../material_app_testing.dart';

void main() {
  testWidgets(
    'given a failure message '
    'when rendered '
    'then shows the message and invokes onRetry when tapped',
    (tester) async {
      var retryTapped = false;

      await tester.pumpWidget(
        MaterialAppTesting(
          builder: (context) => TunerFailureComponent(
            message: 'Microphone access was denied.',
            onRetry: () => retryTapped = true,
          ),
        ),
      );

      expect(find.text('Microphone access was denied.'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(retryTapped, isTrue);
    },
  );
}

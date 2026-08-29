import 'package:flutter_test/flutter_test.dart';
import 'package:violin_app/src/domain/dto/entities/violin_open_string.dart';
import 'package:violin_app/src/external/services/violin_open_string_locator.dart';

void main() {
  const locator = ViolinOpenStringLocator();

  test(
    'given exactly 440Hz '
    'when locate is called '
    'then returns the A4 open string',
    () {
      expect(locator.locate(440), ViolinOpenString.a4);
    },
  );

  test(
    'given exactly 196Hz '
    'when locate is called '
    'then returns the G3 open string',
    () {
      expect(locator.locate(196), ViolinOpenString.g3);
    },
  );

  test(
    'given a frequency far from every open string '
    'when locate is called '
    'then returns null',
    () {
      expect(locator.locate(250), isNull);
    },
  );
}

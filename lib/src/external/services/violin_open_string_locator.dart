import 'dart:math';

import '../../domain/dto/entities/violin_open_string.dart';

/// Locates the nearest violin open string to a measured frequency, or
/// `null` when no open string is close enough to be a useful reference.
class ViolinOpenStringLocator {
  const ViolinOpenStringLocator({this.centsTolerance = 35});

  final double centsTolerance;

  ViolinOpenString? locate(double frequency) {
    ViolinOpenString? closest;
    var smallestCents = double.infinity;

    for (final string in ViolinOpenString.values) {
      final cents = (1200 * (log(frequency / string.frequency) / ln2)).abs();

      if (cents < smallestCents) {
        smallestCents = cents;
        closest = string;
      }
    }

    return smallestCents <= centsTolerance ? closest : null;
  }
}

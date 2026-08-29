import 'dart:math';
import 'dart:typed_data';

/// Estimates the fundamental frequency of a PCM16 mono audio window using
/// normalized autocorrelation with parabolic interpolation of the peak.
class PitchDetector {
  const PitchDetector({
    this.minFrequency = 180,
    this.maxFrequency = 3500,
    this.silenceRmsThreshold = 0.02,
  });

  /// Lowest frequency to search for, in Hz. Just below the violin's open
  /// G string (~196Hz) to tolerate slightly flat tuning.
  final double minFrequency;

  /// Highest frequency to search for, in Hz. Comfortably above the violin's
  /// practical upper range.
  final double maxFrequency;

  /// Windows whose root-mean-square amplitude falls below this (on a 0-1
  /// scale) are treated as silence rather than analyzed.
  final double silenceRmsThreshold;

  /// Returns the estimated frequency in Hz, or `null` if [samples] is too
  /// quiet to contain a reliable pitch.
  double? detectFrequency(Int16List samples, int sampleRate) {
    if (samples.isEmpty) {
      return null;
    }

    final normalized = Float64List(samples.length);
    var sumSquares = 0.0;

    for (var i = 0; i < samples.length; i++) {
      final value = samples[i] / 32768;
      normalized[i] = value;
      sumSquares += value * value;
    }

    final rms = sqrt(sumSquares / samples.length);

    if (rms < silenceRmsThreshold) {
      return null;
    }

    return _autocorrelate(normalized, sampleRate);
  }

  double? _autocorrelate(Float64List samples, int sampleRate) {
    final size = samples.length;
    final minLag = (sampleRate / maxFrequency).floor().clamp(1, size - 2);
    final maxLag = (sampleRate / minFrequency).ceil().clamp(minLag + 1, size - 2);

    final correlations = Float64List(maxLag + 2);
    var bestLag = -1;
    var bestCorrelation = 0.0;

    for (var lag = minLag; lag <= maxLag; lag++) {
      var correlation = 0.0;

      for (var i = 0; i < size - lag; i++) {
        correlation += samples[i] * samples[i + lag];
      }

      correlations[lag] = correlation;

      if (correlation > bestCorrelation) {
        bestCorrelation = correlation;
        bestLag = lag;
      }
    }

    if (bestLag <= minLag || bestLag >= maxLag) {
      return bestLag > 0 ? sampleRate / bestLag : null;
    }

    final refinedLag = _refineLag(correlations, bestLag);

    return sampleRate / refinedLag;
  }

  /// Fits a parabola through the peak correlation and its neighbors to
  /// estimate the true peak lag beyond single-sample resolution.
  double _refineLag(Float64List correlations, int lag) {
    final before = correlations[lag - 1];
    final at = correlations[lag];
    final after = correlations[lag + 1];

    final denominator = before - 2 * at + after;

    if (denominator == 0) {
      return lag.toDouble();
    }

    final offset = 0.5 * (before - after) / denominator;

    return lag + offset;
  }
}

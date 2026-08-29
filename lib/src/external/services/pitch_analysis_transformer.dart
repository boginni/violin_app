import 'dart:async';
import 'dart:typed_data';

import '../../domain/dto/entities/detected_note_entity.dart';
import 'pitch_class_mapper.dart';
import 'pitch_detector.dart';
import 'violin_open_string_locator.dart';

/// Transforms a raw PCM16 mono byte stream (as produced by the microphone
/// datasource) into a stream of detected notes, one per fixed-size
/// analysis window.
class PitchAnalysisTransformer
    extends StreamTransformerBase<Uint8List, DetectedNoteEntity?> {
  const PitchAnalysisTransformer(
    this._pitchDetector,
    this._pitchClassMapper,
    this._openStringLocator, {
    this.sampleRate = 44100,
    this.windowSize = 4096,
  });

  final PitchDetector _pitchDetector;
  final PitchClassMapper _pitchClassMapper;
  final ViolinOpenStringLocator _openStringLocator;
  final int sampleRate;
  final int windowSize;

  @override
  Stream<DetectedNoteEntity?> bind(Stream<Uint8List> stream) async* {
    final buffer = <int>[];

    await for (final chunk in stream) {
      buffer.addAll(_decodePcm16(chunk));

      while (buffer.length >= windowSize) {
        final window = Int16List.fromList(buffer.sublist(0, windowSize));
        // Slide by half a window so consecutive analyses overlap, giving
        // smoother, more frequent updates than non-overlapping windows.
        buffer.removeRange(0, windowSize ~/ 2);

        final frequency = _pitchDetector.detectFrequency(window, sampleRate);

        yield frequency == null ? null : _toDetectedNote(frequency);
      }
    }
  }

  DetectedNoteEntity _toDetectedNote(double frequency) {
    final pitch = _pitchClassMapper.map(frequency);

    return DetectedNoteEntity(
      pitchClass: pitch.pitchClass,
      octave: pitch.octave,
      frequency: frequency,
      expectedFrequency: pitch.expectedFrequency,
      centsOffset: pitch.centsOffset,
      closestOpenString: _openStringLocator.locate(frequency),
    );
  }

  Int16List _decodePcm16(Uint8List bytes) {
    final sampleCount = bytes.length ~/ 2;
    final byteData = ByteData.sublistView(bytes);
    final samples = Int16List(sampleCount);

    for (var i = 0; i < sampleCount; i++) {
      samples[i] = byteData.getInt16(i * 2, Endian.little);
    }

    return samples;
  }
}

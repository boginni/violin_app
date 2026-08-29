import 'dart:typed_data';

import 'package:record/record.dart';

import '../architecture/microphone_failures.dart';
import 'microphone_recorder.dart';

class MicrophoneDatasource {
  const MicrophoneDatasource(this._recorder);

  final MicrophoneRecorder _recorder;

  static const int sampleRate = 44100;

  Future<Stream<Uint8List>> startStream() async {
    final hasPermission = await _recorder.hasPermission();

    if (!hasPermission) {
      throw MicrophonePermissionDeniedFailure(StackTrace.current);
    }

    return _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
      ),
    );
  }

  Future<void> stopStream() async {
    await _recorder.stop();
  }

  /// The stream produced by the most recent [startStream] call, or `null` if
  /// no recording is currently active.
  Stream<Uint8List>? getCurrentStream() => _recorder.getCurrentStream();
}

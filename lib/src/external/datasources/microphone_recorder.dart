import 'dart:typed_data';

import 'package:record/record.dart';

/// Thin wrapper around [AudioRecorder] that also keeps track of the stream
/// returned by the last [start] call, so callers can read the currently
/// active recording stream (e.g. after a rebuild) without holding onto it
/// themselves.
class MicrophoneRecorder {
  MicrophoneRecorder(this._recorder);

  final AudioRecorder _recorder;

  Stream<Uint8List>? _currentStream;

  /// The stream produced by the most recent [start] call, or `null` if no
  /// recording is currently active.
  Stream<Uint8List>? getCurrentStream() => _currentStream;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<Stream<Uint8List>> start(RecordConfig config) async {
    final stream = await _recorder.startStream(config);
    _currentStream = stream;

    return stream;
  }

  Future<void> stop() async {
    await _recorder.stop();
    _currentStream = null;
  }
}

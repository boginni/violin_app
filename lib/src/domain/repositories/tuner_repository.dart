import 'dart:async';

import 'package:error_handler_with_result/error_handler_with_result.dart';

import '../dto/entities/detected_note_entity.dart';

abstract interface class TunerRepository {
  /// Starts capturing microphone audio and returns a stream that emits the
  /// detected note for every analyzed audio window, or `null` when the
  /// window is too quiet for a pitch to be detected.
  Future<Result<Stream<DetectedNoteEntity?>>> startListening();

  /// Stops capturing microphone audio.
  Future<Result<void>> stopListening();

  /// The stream returned by the most recent [startListening] call, or a
  /// successful `null` if no listening session is currently active.
  Result<Stream<DetectedNoteEntity?>?> getCurrentStream();
}

import 'package:error_handler_with_result/error_handler_with_result.dart';

class MicrophonePermissionDeniedFailure extends Failure
    implements PermissionFailure {
  const MicrophonePermissionDeniedFailure(super.stackTrace);

  @override
  bool get isFatal => false;

  @override
  String toString() =>
      'MicrophonePermissionDeniedFailure: microphone access was denied';
}

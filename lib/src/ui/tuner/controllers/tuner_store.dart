import 'dart:async';

import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/dto/entities/detected_note_entity.dart';

class TunerStore extends ChangeNotifier
    implements ValueListenable<TunerStoreState> {
  TunerStoreState _state = TunerStoreState.idle();

  TunerStoreState get state => _state;

  StreamSubscription<void>? subscription;

  set state(TunerStoreState value) {
    _state = value;
    notifyListeners();
  }

  @override
  TunerStoreState get value => _state;
}

sealed class TunerStoreState {
  const TunerStoreState();

  factory TunerStoreState.idle() = TunerStoreIdleState;

  factory TunerStoreState.listening(DetectedNoteEntity? note) =
      TunerStoreListeningState;

  factory TunerStoreState.failure(Failure failure) = TunerStoreFailureState;
}

class TunerStoreIdleState extends TunerStoreState {
  const TunerStoreIdleState();
}

class TunerStoreListeningState extends TunerStoreState {
  const TunerStoreListeningState(this.note);

  final DetectedNoteEntity? note;
}

class TunerStoreFailureState extends TunerStoreState {
  const TunerStoreFailureState(this.failure);

  final Failure failure;
}

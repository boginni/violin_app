import 'dart:async';

import 'package:error_handler_with_result/error_handler_with_result.dart';

import '../../../domain/repositories/tuner_repository.dart';
import 'tuner_store.dart';

class TunerController {
  final TunerRepository repository;
  final TunerStore store;

  TunerController(this.repository, {required this.store});

  Future<void> start() async {
    if (store.state is TunerStoreListeningState) {
      return;
    }

    store.state = TunerStoreState.listening(null);

    final result = await repository.startListening();

    if (result.isFailure) {
      store.state = TunerStoreState.failure(result.failure);

      if (result.failure.isFatal) {
        result.failure.throwError();
      }

      return;
    }

    await store.subscription?.cancel();
    store.subscription = result.success.listen(
      (note) => store.state = TunerStoreState.listening(note),
      onError: (Object error, StackTrace stackTrace) {
        store.state = TunerStoreState.failure(
          UnknownFailure(error, stackTrace),
        );
      },
    );
  }

  Future<void> stop() async {
    await store.subscription?.cancel();
    store.subscription = null;

    final result = await repository.stopListening();

    store.state = TunerStoreState.idle();

    if (result.isFailure && result.failure.isFatal) {
      result.failure.throwError();
    }
  }

  void dispose() {
    unawaited(store.subscription?.cancel());
  }
}

import 'package:error_handler_with_result/error_handler_with_result.dart';
import 'package:flutter/material.dart';
import 'package:violin_l10n/violin_l10n.dart';

import '../components/tuner_failure_component.dart';
import '../components/tuner_idle_component.dart';
import '../components/tuner_listening_component.dart';
import '../controllers/tuner_controller.dart';
import '../controllers/tuner_store.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({
    super.key,
    required this.controller,
  });

  final TunerController controller;

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  TunerController get controller => widget.controller;

  TunerStore get store => controller.store;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String failureToString(Failure failure) {
    if (failure is PermissionFailure) {
      return context.l10n.microphone_permission_denied;
    }

    return context.l10n.unknown_error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.violin_tuner),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, child) {
          return switch (store.state) {
            TunerStoreIdleState() => TunerIdleComponent(
              onStart: controller.start,
            ),
            TunerStoreListeningState(:final note) => TunerListeningComponent(
              note: note,
              onStop: controller.stop,
            ),
            TunerStoreFailureState(:final failure) => TunerFailureComponent(
              message: failureToString(failure),
              onRetry: controller.start,
            ),
          };
        },
      ),
    );
  }
}

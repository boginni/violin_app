import 'package:flutter/material.dart';
import 'package:violin_l10n/violin_l10n.dart';

import '../../app/extensions/context_extensions.dart';

class TunerIdleComponent extends StatelessWidget {
  const TunerIdleComponent({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        spacing: 16,
        children: [
          Icon(
            Icons.mic_none,
            size: 96,
            color: context.colorScheme.primary,
          ),
          Text(
            context.l10n.tuner_listening_hint,
            style: context.textTheme.bodyLarge,
            textAlign: .center,
          ),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.mic),
            label: Text(context.l10n.tuner_start_listening),
          ),
        ],
      ),
    );
  }
}

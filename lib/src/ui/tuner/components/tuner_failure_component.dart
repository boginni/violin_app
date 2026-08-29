import 'package:flutter/material.dart';
import 'package:violin_l10n/violin_l10n.dart';

import '../../app/extensions/context_extensions.dart';

class TunerFailureComponent extends StatelessWidget {
  const TunerFailureComponent({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisSize: .min,
          spacing: 16,
          children: [
            Icon(
              Icons.mic_off,
              size: 96,
              color: context.colorScheme.error,
            ),
            Text(
              message,
              style: context.textTheme.bodyLarge,
              textAlign: .center,
            ),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.tuner_try_again),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:violin_l10n/violin_l10n.dart';

class ShortenHistoryEmptyComponent extends StatelessWidget {
  const ShortenHistoryEmptyComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Text(context.l10n.empty),
          ),
        ),
      ],
    );
  }
}

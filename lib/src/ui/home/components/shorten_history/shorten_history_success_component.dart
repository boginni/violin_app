import 'package:flutter/material.dart';
import 'package:violin_l10n/violin_l10n.dart';

import '../../../../domain/dto/entities/shortened_url_entity.dart';
import '../../../app/extensions/context_extensions.dart';
import '../shortened_url_list_tile.dart';

class ShortenHistoryComponent extends StatelessWidget {
  const ShortenHistoryComponent({
    super.key,
    required this.entities,
    required this.onTap,
  });

  final List<ShortenedUrlEntity> entities;
  final ValueSetter<ShortenedUrlEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const .only(bottom: 16),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: Text(
                context.l10n.showing_x_history(entities.length),
                style: context.textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const .symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: entities.length,
            separatorBuilder: (context, index) {
              final entity = entities.elementAtOrNull(index);

              if (entity == null) {
                return null;
              }

              return const SizedBox(
                height: 16,
              );
            },
            itemBuilder: (context, int index) {
              final entity = entities.elementAtOrNull(index);

              if (entity == null) {
                return null;
              }

              return ShortenedUrlListTile(
                entity: entity,
                onTap: () => onTap(entity),
              );
            },
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Text(context.l10n.end_of_history),
          ),
        ),
      ],
    );
  }
}

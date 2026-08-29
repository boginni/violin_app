import 'package:flutter/material.dart';
import 'package:violin_design_system/violin_design_system.dart';

import '../../../domain/dto/entities/shortened_url_entity.dart';
import '../../../domain/environment.dart';
import '../../app/extensions/context_extensions.dart';

class ShortenedUrlListTile extends StatelessWidget {
  final ShortenedUrlEntity entity;
  final VoidCallback onTap;

  const ShortenedUrlListTile({
    super.key,
    required this.entity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: .zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaviconImage(
                  url: entity.originalUrl,
                  size: 32,
                  proxyUrl: Environment.faviconProxy,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    entity.url,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  color: colorScheme.secondary,
                  onPressed: onTap,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              entity.originalUrl,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

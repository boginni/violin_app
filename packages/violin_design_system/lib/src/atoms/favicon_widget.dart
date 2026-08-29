import 'package:flutter/material.dart';

import 'place_holder_image.dart';

class FaviconImage extends StatelessWidget {
  final String? url;
  final double size;
  final String proxyUrl;

  const FaviconImage({
    super.key,
    this.url,
    this.size = 48.0,
    required this.proxyUrl,
  });

  String? getFavicon(
    String url, {
    int? size,
  }) {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(
      trimmedUrl.startsWith(RegExp('https?://'))
          ? trimmedUrl
          : 'https://$trimmedUrl',
    );

    final host = uri?.host;

    if (host == null) {
      return null;
    }

    final corsWrapperUri = Uri.tryParse(proxyUrl)?.replace(
      queryParameters: {
        'domain': host,
        'sz': ?size?.toString(),
      },
    );

    return corsWrapperUri?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final favicon = getFavicon(
      url ?? '',
      size: size.toInt(),
    );

    if (favicon == null) {
      return PlaceHolderImage(
        size: size,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.15),
      child: Image.network(
        favicon,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return PlaceHolderImage(
            size: size,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return PlaceHolderImage(
            size: size,
          );
        },
      ),
    );
  }
}

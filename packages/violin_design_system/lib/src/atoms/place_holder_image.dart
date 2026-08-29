import 'package:flutter/material.dart';
import 'package:violin_assets/violin_assets.dart';

class PlaceHolderImage extends StatelessWidget {
  const PlaceHolderImage({
    super.key,
    this.size,
  });

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ViolinAssetsResources.placeholderImagePng,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

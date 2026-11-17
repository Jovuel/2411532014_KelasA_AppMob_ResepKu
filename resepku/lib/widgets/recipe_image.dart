import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({super.key, required this.url, this.cacheWidth});

  final String url;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context){
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: cacheWidth?.toDouble(),
      memCacheWidth: cacheWidth,
      placeholder: (context, url) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.restaurant_menu)),
      ),
      errorWidget: (context, url, error) {
        return Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
      },
    );
  }
}

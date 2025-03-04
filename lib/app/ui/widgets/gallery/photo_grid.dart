import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PhotoGrid extends StatelessWidget {
  final List<PhotoModel> photos;
  final Function(int) onPhotoTap;
  final Map<String, String> secureUrls; // Nuevo parámetro

  const PhotoGrid({
    Key? key,
    required this.photos,
    required this.onPhotoTap,
    required this.secureUrls, // Añadir este parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          final String key = '${photo.id}_thumb';
          final String url = secureUrls.containsKey(key)
              ? secureUrls[key]!
              : photo.thumbnailUrl;

          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 3,
            duration: const Duration(milliseconds: 375),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: PhotoGridItem(
                  photo: photo,
                  onTap: () => onPhotoTap(index),
                  secureUrl: url, // Pasar URL segura
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PhotoGridItem extends StatelessWidget {
  final PhotoModel photo;
  final VoidCallback onTap;
  final String secureUrl; // Añadir este parámetro

  const PhotoGridItem({
    Key? key,
    required this.photo,
    required this.onTap,
    required this.secureUrl, // Nuevo parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'photo_${photo.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: secureUrl, // Usar URL segura
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

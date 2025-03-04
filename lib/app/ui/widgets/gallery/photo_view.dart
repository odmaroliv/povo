import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoView extends StatelessWidget {
  final PhotoModel photo;
  final String userName;
  final bool isLiked;
  final int likesCount;
  final VoidCallback onClose;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final String secureUrl; // Nuevo parámetro

  const PhotoView({
    Key? key,
    required this.photo,
    required this.userName,
    required this.isLiked,
    required this.likesCount,
    required this.onClose,
    this.onNext,
    this.onPrevious,
    required this.onLike,
    required this.onShare,
    required this.onDownload,
    required this.secureUrl, // Añadir este parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Stack(
      fit: StackFit.expand,
      children: [
        // Black Background
        Container(
          color: Colors.black,
        ),

        // Main Photo with Gestures
        GestureDetector(
          onTap: () {
            // Toggle top and bottom controls visibility
          },
          onHorizontalDragEnd: (details) {
            // Swipe left or right
            if (details.primaryVelocity! > 0 && onPrevious != null) {
              // Swipe right - previous photo
              onPrevious!();
            } else if (details.primaryVelocity! < 0 && onNext != null) {
              // Swipe left - next photo
              onNext!();
            }
          },
          child: Hero(
            tag: 'photo_${photo.id}',
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: CachedNetworkImage(
                  imageUrl: secureUrl, // Usar URL segura
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Previous Button
        if (onPrevious != null)
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: onPrevious,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 30,
                ),
                tooltip: 'Anterior',
              ),
            ),
          ),

        // Next Button
        if (onNext != null)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: onNext,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 30,
                ),
                tooltip: 'Siguiente',
              ),
            ),
          ),

        // Top Bar (Close Button)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onShare,
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        tooltip: 'Compartir',
                      ),
                      IconButton(
                        onPressed: onDownload,
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        tooltip: 'Descargar',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Info Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  if (photo.caption != null && photo.caption!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        photo.caption!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  // User and Date Info
                  Row(
                    children: [
                      // User info
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Date info
                      Text(
                        dateFormat.format(photo.uploadedAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Likes and Actions Row
                  Row(
                    children: [
                      // Like Button
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              likesCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

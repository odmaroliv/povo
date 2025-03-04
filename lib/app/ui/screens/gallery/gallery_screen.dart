import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/gallery_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/ui/widgets/common/loading_widget.dart';
import 'package:povo/app/ui/widgets/common/error_widget.dart';
import 'package:povo/app/ui/widgets/gallery/photo_grid.dart';
import 'package:povo/app/ui/widgets/gallery/photo_view.dart';

class GalleryScreen extends GetView<GalleryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.currentEvent.value?.name ?? 'Galería',
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshGallery,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        if (controller.hasError.value) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshGallery,
          );
        }

        if (controller.photos.isEmpty) {
          return _buildEmptyGallery();
        }

        return _buildGalleryContent();
      }),
    );
  }

  Widget _buildEmptyGallery() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay fotos en este evento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en capturar un momento',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to camera
              Get.back();
              Get.toNamed('/camera',
                  arguments: controller.currentEventId.value);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Tomar una foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryContent() {
    return Column(
      children: [
        Expanded(
          child: controller.currentPhotoIndex.value == -1
              ? _buildPhotoGrid()
              : _buildPhotoViewer(),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return PhotoGrid(
      photos: controller.photos,
      onPhotoTap: (index) {
        controller.setCurrentPhotoIndex(index);
      },
      secureUrls: controller.securePhotoUrls, // Pasar URLs seguras
    );
  }

  Widget _buildPhotoViewer() {
    return Obx(() {
      if (controller.photos.isEmpty ||
          controller.currentPhotoIndex.value >= controller.photos.length) {
        return const Center(
          child: Text('No hay fotos para mostrar'),
        );
      }

      final currentPhoto =
          controller.photos[controller.currentPhotoIndex.value];
      final userName = controller.getUserName(currentPhoto.userId);
      final isLiked = controller.isPhotoLiked(currentPhoto.id);
      final likesCount = controller.getLikesCount(currentPhoto.id);
      final secureUrl =
          controller.getSecureUrl(currentPhoto.id, isThumb: false);

      return PhotoView(
        photo: currentPhoto,
        userName: userName,
        isLiked: isLiked,
        likesCount: likesCount,
        secureUrl: secureUrl, // Pasar URL segura
        onClose: () {
          controller.currentPhotoIndex.value = -1;
        },
        onNext:
            controller.currentPhotoIndex.value < controller.photos.length - 1
                ? controller.nextPhoto
                : null,
        onPrevious: controller.currentPhotoIndex.value > 0
            ? controller.previousPhoto
            : null,
        onLike: () {
          if (isLiked) {
            controller.unlikePhoto(currentPhoto.id);
          } else {
            controller.likePhoto(currentPhoto.id);
          }
        },
        onShare: () => controller.sharePhoto(secureUrl), // Usar URL segura
        onDownload: () =>
            controller.downloadPhoto(secureUrl), // Usar URL segura
      );
    });
  }
}

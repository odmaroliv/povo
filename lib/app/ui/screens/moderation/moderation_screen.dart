import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/moderator_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:povo/app/ui/widgets/common/loading_widget.dart';
import 'package:povo/app/ui/widgets/common/error_widget.dart';
import 'package:povo/app/ui/widgets/moderation/photo_approval_card.dart';

class ModerationScreen extends GetView<ModeratorController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderación de fotos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
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
            onRetry: controller.refreshData,
          );
        }

        if (controller.currentEvent.value == null) {
          return const Center(
            child: Text('Evento no encontrado'),
          );
        }

        return _buildContent();
      }),
      floatingActionButton: Obx(() => controller.pendingPhotos.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: controller.approveAllPendingPhotos,
              icon: const Icon(Icons.check_circle),
              label: const Text('Aprobar todas'),
              backgroundColor: Colors.green,
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: ColorConstants.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: ColorConstants.primaryColor,
              tabs: [
                Tab(
                  text: 'Pendientes (${controller.pendingPhotos.length})',
                  icon: const Icon(Icons.timer),
                ),
                Tab(
                  text: 'Aprobadas (${controller.approvedPhotos.length})',
                  icon: const Icon(Icons.check_circle),
                ),
                Tab(
                  text: 'Rechazadas (${controller.rejectedPhotos.length})',
                  icon: const Icon(Icons.cancel),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pending Photos
                _buildPhotosList(
                  controller.pendingPhotos,
                  'No hay fotos pendientes de aprobación',
                  isPending: true,
                ),

                // Approved Photos
                _buildPhotosList(
                  controller.approvedPhotos,
                  'No has aprobado ninguna foto',
                  isApproved: true,
                ),

                // Rejected Photos
                _buildPhotosList(
                  controller.rejectedPhotos,
                  'No has rechazado ninguna foto',
                  isRejected: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosList(
    List<PhotoModel> photos,
    String emptyMessage, {
    bool isPending = false,
    bool isApproved = false,
    bool isRejected = false,
  }) {
    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending
                  ? Icons.timer_outlined
                  : isApproved
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoApprovalCard(
          photo: photo,
          userName: controller.getUserName(photo.userId),
          onApprove: isPending ? () => controller.approvePhoto(photo) : null,
          onReject: isPending ? () => controller.rejectPhoto(photo) : null,
          onDelete: () => _showDeletePhotoDialog(context, photo),
          showActions: isPending,
        );
      },
    );
  }

  void _showDeletePhotoDialog(BuildContext context, PhotoModel photo) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta foto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deletePhoto(photo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

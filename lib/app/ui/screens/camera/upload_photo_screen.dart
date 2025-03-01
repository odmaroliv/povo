import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/photo_upload_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';

class UploadPhotoScreen extends GetView<PhotoUploadController> {
  // Se espera que se reciba el eventId en los argumentos
  final String eventId =
      Get.arguments != null && Get.arguments['eventId'] != null
          ? Get.arguments['eventId']
          : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subir Imágenes"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.hasError.value)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConstants.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.pickMultipleImages,
                icon: const Icon(Icons.photo_library),
                label: const Text("Seleccionar imágenes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColorDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              // Vista previa de las imágenes seleccionadas en Grid
              controller.selectedImages.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: controller.selectedImages.length,
                      itemBuilder: (context, index) {
                        final File image = controller.selectedImages[index];
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () =>
                                    controller.selectedImages.removeAt(index),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text("No hay imágenes seleccionadas"),
                      ),
                    ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.captionController,
                decoration: const InputDecoration(
                  labelText: "Descripción (opcional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.uploadMultipleImages(eventId),
                child: const Text("Subir imágenes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/camera_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/ui/widgets/camera/camera_controls.dart';
import 'package:povo/app/ui/widgets/camera/filter_selector.dart';
import 'package:povo/app/ui/widgets/common/loading_widget.dart';
import 'package:povo/app/ui/widgets/common/error_widget.dart';

class CameraScreen extends GetView<CameraController> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (!controller.isLoading.value && controller.hasError.value) {
            return CustomErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.initializeCamera,
            );
          }

          return Stack(
            children: [
              // Camera Preview
              Positioned.fill(
                child: _buildCameraPreview(),
              ),

              // Loading Indicator
              if (controller.isLoading.value)
                const Positioned.fill(
                  child: LoadingWidget(),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return CameraAwesomeBuilder.awesome(
      saveConfig: SaveConfig.photo(),
      sensorConfig: controller.getCameraConfig(),
      previewFit: CameraPreviewFit.cover,
      onMediaCaptureEvent: (event) {
        if (event.status == MediaCaptureStatus.success && event.isPicture) {
          event.captureRequest.when(
            single: (single) {
              if (single.file != null) {
                controller.capturedImagePath.value = single.file!.path;
                Get.toNamed(AppRoutes.PHOTO_PREVIEW);
              }
            },
            multiple: (_) {},
          );
        }
      },
      imageAnalysisConfig: AnalysisConfig(
        androidOptions: const AndroidAnalysisOptions.nv21(
          width: 250,
        ),
        autoStart: true,
      ),
      topActionsBuilder: (state) {
        // Asignar el estado de la cámara
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.updateCameraState(state);
        });

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Get.back(),
            ),
            Obx(() => IconButton(
                  icon: Icon(
                    controller.isFlashOn.value
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: controller.toggleFlash,
                )),
          ],
        );
      },
      bottomActionsBuilder: (state) {
        return Column(
          children: [
            // Filter Selector
            FilterSelector(
              filters: controller.availableFilters,
              currentFilter: controller.currentFilter.value,
              onFilterSelected: controller.selectFilter,
            ),

            const SizedBox(height: 20),

            // Camera Controls (Capture Button, Switch Camera)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch Camera Button
                IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    controller.toggleCamera();
                    state.when(
                      onPhotoMode: (photoState) {
                        // Usar el método switchCameraSensor correctamente con parámetros nombrados
                        photoState.switchCameraSensor();
                      },
                      onVideoMode: (videoState) {
                        videoState.switchCameraSensor();
                      },
                      onVideoRecordingMode: (_) {},
                      onPreparingCamera: (_) {},
                    );
                  },
                ),

                // Capture Button
                GestureDetector(
                  onTap: controller.isCapturing.value
                      ? null
                      : () {
                          controller.isCapturing.value = true;
                          state.when(
                            onPhotoMode: (photoState) async {
                              try {
                                await photoState.takePhoto();
                              } finally {
                                controller.isCapturing.value = false;
                              }
                            },
                            onVideoMode: (_) {},
                            onVideoRecordingMode: (_) {},
                            onPreparingCamera: (_) {},
                          );
                        },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: controller.isCapturing.value
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const SizedBox(),
                  ),
                ),

                // Placeholder para mantener centrado el botón de captura
                const SizedBox(width: 50, height: 50),
              ],
            ),
          ],
        );
      },
      theme: AwesomeTheme(
        bottomActionsBackgroundColor: Colors.transparent,
      ),
    );
  }
}

// Missing PhotoPreviewScreen
class PhotoPreviewScreen extends GetView<CameraController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.capturedImagePath.value.isEmpty) {
            return const Center(
              child: Text(
                'No hay imagen para mostrar',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              // Image Preview - CORREGIDO
              Positioned.fill(
                child: Image.file(
                  File(controller.capturedImagePath
                      .value), // Crear File a partir del String
                  fit: BoxFit.contain,
                ),
              ),
              // Top Bar with Close Button
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: controller.discardPhoto,
                    ),
                  ],
                ),
              ),

              // Bottom Controls (Use Photo, Retake)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    children: [
                      // Caption Text Field
                      TextField(
                        controller: controller.captionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Añadir una descripción... (opcional)',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Retake Button
                          TextButton.icon(
                            onPressed: controller.discardPhoto,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Volver a tomar',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),

                          // Upload Button
                          Obx(() => ElevatedButton.icon(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.uploadPhoto,
                                icon: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.check),
                                label: const Text('Usar foto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstants.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Indicator
              if (controller.isLoading.value)
                const Positioned.fill(
                  child: LoadingWidget(),
                ),
            ],
          );
        }),
      ),
    );
  }
}

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
            // FilterSelector(
            //   filters: controller.availableFilters,
            //   currentFilter: controller.currentFilter.value,
            //   onFilterSelected: controller.selectFilter,
            // ),

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
            const SizedBox(height: 20),
          ],
        );
      },
      theme: AwesomeTheme(
        bottomActionsBackgroundColor: Colors.transparent,
      ),
    );
  }
}

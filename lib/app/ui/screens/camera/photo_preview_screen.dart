// Missing PhotoPreviewScreen
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:povo/app/controllers/camera_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/ui/widgets/common/loading_widget.dart';

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
        } as WidgetCallback),
      ),
    );
  }
}

import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:povo/app/data/repositories/photo_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/camera_service.dart';

class CameraController extends GetxController {
  final CameraService _cameraService = Get.find<CameraService>();
  final PhotoRepository _photoRepository = Get.find<PhotoRepository>();
  final AuthService _authService = Get.find<AuthService>();

  // State variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isCapturing = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxString currentEventId = ''.obs;
  final RxString capturedImagePath = ''.obs;
  final TextEditingController captionController = TextEditingController();

  // Camera controller from CameraAwesome
  Rx<CameraState?> get cameraState => _cameraService.cameraState;
  RxList<AwesomeFilter> get availableFilters => _cameraService.availableFilters;
  Rx<AwesomeFilter> get currentFilter => _cameraService.currentFilter;

  // Getters
  String get userId => _authService.userId!;

  @override
  void onInit() {
    super.onInit();
    // Get event ID from arguments if available
    if (Get.arguments != null) {
      currentEventId.value = Get.arguments as String;
    }
    initializeCamera();
  }

  // Initialize the camera
  Future<void> initializeCamera() async {
    try {
      await _cameraService.initCamera();

      // Update local variables to reflect service state
      isFrontCamera.value = _cameraService.isFrontCamera.value;
      isFlashOn.value = _cameraService.isFlashOn.value;
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'No se pudo inicializar la cámara. Verifique los permisos.';
      print('Error initializing camera: $e');
    }
  }

  // Capture a photo
  Future<void> capturePhoto() async {
    if (isCapturing.value) return;

    try {
      isCapturing.value = true;

      // Take the picture
      final imagePath = await _cameraService.takePicture();
      capturedImagePath.value = imagePath;

      // Navigate to preview page
      Get.toNamed(AppRoutes.PHOTO_PREVIEW);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo capturar la foto. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error capturing photo: $e');
    } finally {
      isCapturing.value = false;
    }
  }

  // Upload the captured photo
  Future<void> uploadPhoto() async {
    if (capturedImagePath.value.isEmpty || currentEventId.value.isEmpty) return;

    try {
      isLoading.value = true;

      final photo = await _photoRepository.uploadPhoto(
        photoPath: capturedImagePath.value,
        eventId: currentEventId.value,
        userId: userId,
        caption: captionController.text.trim(),
        filter: {
          'name': currentFilter.value.name,
        },
      );

      Get.until((route) => route.settings.name == AppRoutes.EVENT_DETAILS);

      Get.snackbar(
        'Éxito',
        'Foto subida correctamente. Esperando aprobación.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Clear captured image path and caption
      capturedImagePath.value = '';
      captionController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo subir la foto. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error uploading photo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Discard the captured photo
  void discardPhoto() {
    try {
      if (capturedImagePath.value.isNotEmpty) {
        final file = File(capturedImagePath.value);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }

      capturedImagePath.value = '';
      captionController.clear();

      // Navigate back to camera
      Get.back();
    } catch (e) {
      print('Error discarding photo: $e');
    }
  }

  // Toggle camera (front/back)
  void toggleCamera() {
    _cameraService.toggleCamera();
    isFrontCamera.value = _cameraService.isFrontCamera.value;
  }

  // Toggle flash
  void toggleFlash() {
    _cameraService.toggleFlash();
    isFlashOn.value = _cameraService.isFlashOn.value;
  }

  // Select a filter
  void selectFilter(AwesomeFilter filter) {
    _cameraService.setFilter(filter);
  }

  // Get camera configuration
  SensorConfig getCameraConfig() {
    return _cameraService.getSensorConfig();
  }

  // Set zoom level
  void setZoomLevel(double zoom) {
    _cameraService.setZoomLevel(zoom);
  }

  @override
  void onClose() {
    captionController.dispose();
    _cameraService.dispose();
    super.onClose();
  }
}

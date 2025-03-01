import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // Cámara: estado y filtros
  Rx<CameraState?> get cameraState => _cameraService.cameraState;
  RxList<AwesomeFilter> get availableFilters => _cameraService.availableFilters;
  Rx<AwesomeFilter> get currentFilter => _cameraService.currentFilter;

  // Getters
  String get userId => _authService.userId!;

  @override
  void onInit() {
    super.onInit();
    // Si hay argumentos, extraer eventId
    if (Get.arguments != null) {
      if (Get.arguments is String) {
        currentEventId.value = Get.arguments as String;
      } else if (Get.arguments is Map) {
        Map args = Get.arguments as Map;
        if (args.containsKey('eventId')) {
          currentEventId.value = args['eventId'].toString();
        }
      }
    }
    // Retrasar la inicialización hasta después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeCamera();
    });
  }

  // Inicializar la cámara con un pequeño retraso y reintento en caso de error
  Future<void> initializeCamera({int retryCount = 0}) async {
    try {
      print("Inicializando cámara...");
      await Future.delayed(const Duration(milliseconds: 300));

      print("Permisos concedidos. Inicializando cámara...");
      await _cameraService.initCamera();
      print("Estado de la cámara: ${_cameraService.cameraState.value}");
      // Espera a que el estado de la cámara esté disponible
      await Future.delayed(const Duration(
          seconds: 1)); // Espera 1 segundo (ajusta según sea necesario)
      if (_cameraService.cameraState.value == null) {
        throw Exception("El estado de la cámara no está disponible");
      }

      print("Cámara inicializada correctamente.");
      isFrontCamera.value = _cameraService.isFrontCamera.value;
      isFlashOn.value = _cameraService.isFlashOn.value;
      hasError.value = false;
    } catch (e) {
      print("Error inicializando cámara: $e");
      if (e.toString().contains("EventSink is closed") && retryCount < 3) {
        print("Reintentando inicialización...");
        await Future.delayed(const Duration(seconds: 1));
        await initializeCamera(retryCount: retryCount + 1);
        return;
      }
      hasError.value = true;
      errorMessage.value =
          'No se pudo inicializar la cámara. Verifique los permisos.';
      print('Error initializing camera: $e');
    }
  }

  // Capturar foto
  Future<void> capturePhoto() async {
    if (isCapturing.value) return;

    try {
      isCapturing.value = true;

      // En lugar de intentar acceder al estado, utiliza directamente la API
      // La foto se capturará y será manejada por onMediaCaptureEvent en el widget
      // No necesitas asignar capturedImagePath aquí
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

  // Subir la foto capturada
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

      // Limpiar imagen y descripción
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

// Método público para actualizar el estado de la cámara
  void updateCameraState(CameraState state) {
    _cameraService.cameraState.value = state;
    print("Estado de la cámara actualizado: ${state.runtimeType}");
  }

  // Desechar la foto capturada
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
      // Volver a la cámara
      Get.back();
    } catch (e) {
      print('Error discarding photo: $e');
    }
  }

  // Alternar entre cámara frontal y trasera
  void toggleCamera() {
    _cameraService.toggleCamera();
    isFrontCamera.value = _cameraService.isFrontCamera.value;
  }

  // Alternar flash
  void toggleFlash() {
    _cameraService.toggleFlash();
    isFlashOn.value = _cameraService.isFlashOn.value;
  }

  // Seleccionar filtro
  void selectFilter(AwesomeFilter filter) {
    _cameraService.setFilter(filter);
  }

  // Obtener configuración de la cámara
  SensorConfig getCameraConfig() {
    return _cameraService.getSensorConfig();
  }

  // Establecer nivel de zoom
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

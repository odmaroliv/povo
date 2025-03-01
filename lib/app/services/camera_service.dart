import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:povo/app/services/storage_service.dart';

class CameraService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  // Estado de la cámara y configuraciones
  final Rx<CameraState?> cameraState = Rx<CameraState?>(null);
  final RxBool hasPermission = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isFlashOn = false.obs;

  // Control de zoom (opcional)
  final RxDouble zoomLevel = 1.0.obs;

  // Filtros disponibles y filtro actual
  final RxList<AwesomeFilter> availableFilters = <AwesomeFilter>[
    AwesomeFilter.None,
    AwesomeFilter.AddictiveRed,
    AwesomeFilter.AddictiveBlue,
    AwesomeFilter.Aden,
    AwesomeFilter.Amaro,
    AwesomeFilter.Ashby,
    AwesomeFilter.Brannan,
    AwesomeFilter.Brooklyn,
    AwesomeFilter.Clarendon,
    AwesomeFilter.Crema,
    AwesomeFilter.Dogpatch,
    AwesomeFilter.Gingham,
    AwesomeFilter.Ginza,
    AwesomeFilter.Hefe,
    AwesomeFilter.Hudson,
    AwesomeFilter.Inkwell,
    AwesomeFilter.Juno,
    AwesomeFilter.Lark,
    AwesomeFilter.LoFi,
    AwesomeFilter.Ludwig,
    AwesomeFilter.Moon,
    AwesomeFilter.Perpetua,
    AwesomeFilter.Reyes,
    AwesomeFilter.Sierra,
    AwesomeFilter.Slumber,
    AwesomeFilter.Stinson,
    AwesomeFilter.Sutro,
    AwesomeFilter.Walden,
    AwesomeFilter.Willow,
    AwesomeFilter.XProII,
  ].obs;
  final Rx<AwesomeFilter> currentFilter = AwesomeFilter.None.obs;

  /// Inicializa la cámara solicitando primero los permisos necesarios.
  Future<void> initCamera() async {
    await _checkAndRequestPermissions();
    isInitialized.value = true;
    // No crees aquí el CameraAwesomeBuilder
  }

  /// Solicita permisos de cámara y micrófono.
  Future<void> _checkAndRequestPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    print('Verificando permisos...');

    if (!cameraStatus.isGranted) {
      print("Permiso de cámara no concedido. Solicitando permisos...");
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        if (result.isPermanentlyDenied) {
          print("Permiso de cámara denegado permanentemente.");
          await openAppSettings();
          throw Exception(
              "Permiso de cámara denegado permanentemente. Habilítalo manualmente en la configuración.");
        } else {
          throw Exception("Permiso de cámara denegado.");
        }
      }
    }

    if (!storageStatus.isGranted) {
      print("Permiso de almacenamiento no concedido. Solicitando permisos...");
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        if (result.isPermanentlyDenied) {
          print("Permiso de almacenamiento denegado permanentemente.");
          await openAppSettings();
          throw Exception(
              "Permiso de almacenamiento denegado permanentemente. Habilítalo manualmente en la configuración.");
        } else {
          throw Exception("Permiso de almacenamiento denegado.");
        }
      }
    }

    print("Permisos concedidos.");
  }

  /// Alterna entre cámara frontal y trasera.
  void toggleCamera() {
    isFrontCamera.value = !isFrontCamera.value;
  }

  /// Alterna el estado del flash.
  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
  }

  /// Establece el filtro actual.
  void setFilter(AwesomeFilter filter) {
    currentFilter.value = filter;
  }

  /// Obtiene la configuración del sensor según el estado actual.
  SensorConfig getSensorConfig() {
    return SensorConfig.single(
      flashMode: isFlashOn.value ? FlashMode.always : FlashMode.none,
      aspectRatio: CameraAspectRatios.ratio_4_3,
      sensor: Sensor.position(
        isFrontCamera.value ? SensorPosition.front : SensorPosition.back,
      ),
    );
  }

  /// Retorna el nivel actual de zoom.
  double getZoomLevel() {
    return zoomLevel.value;
  }

  /// Actualiza el nivel de zoom (debes implementar la lógica en el widget si es necesario).
  void setZoomLevel(double zoom) {
    zoomLevel.value = zoom;
    // Aquí puedes llamar a la API de Camerawesome para actualizar el zoom si la librería lo soporta.
  }

  void setCameraState(CameraState state) {
    cameraState.value = state;
  }

  /// Toma una foto usando el estado actual de la cámara.
  /// Aplica el filtro seleccionado (si es distinto de None) y comprime la imagen.
  /// Retorna la ruta final del archivo.
  Future<String> takePicture() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final originalPath = '${tempDir.path}/$fileName';
      String? capturedPath;

      if (cameraState.value == null) {
        throw Exception("El estado de la cámara no está disponible");
      }

      await cameraState.value!.when(
        onPhotoMode: (photoState) async {
          final captureRequest = await photoState.takePhoto();
          capturedPath = captureRequest.path;
        },
        onVideoMode: (_) async {},
        onVideoRecordingMode: (_) async {},
        onPreparingCamera: (_) async {},
      );

      if (capturedPath == null) {
        throw Exception("No se pudo capturar la foto");
      }

      File processedFile = File(capturedPath!);

      // Aplicar filtro si corresponde
      if (currentFilter.value != AwesomeFilter.None) {
        final bytes = await processedFile.readAsBytes();
        final uiImage = await decodeImageFromList(bytes);
        final Uint8List filteredBytes =
            await applyFilterToImage(uiImage, currentFilter.value);
        final filteredPath = '${tempDir.path}/filtered_$fileName';
        await File(filteredPath).writeAsBytes(filteredBytes);
        processedFile = File(filteredPath);
      }

      // Comprimir la imagen y guardar en originalPath
      final compressedFile =
          await compressImage(processedFile.path, originalPath);
      return compressedFile.path;
    } catch (e) {
      print('Error taking picture: $e');
      rethrow;
    }
  }

  /// Aplica un filtro a la imagen usando un canvas.
  /// Retorna los bytes de la imagen filtrada en formato PNG.
  Future<Uint8List> applyFilterToImage(
      ui.Image image, AwesomeFilter filter) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..colorFilter = filter.preview;
    canvas.drawImage(image, Offset.zero, paint);
    final picture = recorder.endRecording();
    final filteredImage = await picture.toImage(image.width, image.height);
    final byteData =
        await filteredImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception("Error al aplicar el filtro a la imagen");
    }
    return byteData.buffer.asUint8List();
  }

  /// Comprime la imagen ubicada en inputPath y la guarda en outputPath.
  /// Retorna el archivo comprimido.
  Future<File> compressImage(String inputPath, String outputPath) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      inputPath,
      outputPath,
      quality: 85,
    );
    if (result == null) {
      throw Exception("Error al comprimir la imagen");
    }
    return File(result.path);
  }

  /// Genera un thumbnail de la imagen ubicada en imagePath.
  Future<String> generateThumbnail(String imagePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailFileName = 'thumb_${const Uuid().v4()}.jpg';
      final thumbnailPath = '${tempDir.path}/$thumbnailFileName';
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        thumbnailPath,
        quality: 70,
        minWidth: 300,
        minHeight: 300,
      );
      if (result == null) {
        throw Exception("Error al generar el thumbnail");
      }
      return result.path;
    } catch (e) {
      print('Error generating thumbnail: $e');
      rethrow;
    }
  }

  /// Sube la foto junto con su thumbnail.
  /// Retorna un mapa con las URLs de la foto y del thumbnail.
  Future<Map<String, String>> uploadPhotoWithThumbnail(
      String photoPath, String eventId) async {
    try {
      final thumbnailPath = await generateThumbnail(photoPath);
      final fileName = 'event_$eventId/${const Uuid().v4()}.jpg';
      final thumbnailFileName = 'event_$eventId/thumb_${const Uuid().v4()}.jpg';

      // Usar el nuevo método que crea los directorios si no existen
      final photoUrl = await _storageService.uploadPhotoToPath(
          photoPath, 'photos/$fileName');
      final thumbnailUrl = await _storageService.uploadPhotoToPath(
          thumbnailPath, 'thumbnails/$thumbnailFileName');

      return {
        'photoUrl': photoUrl,
        'thumbnailUrl': thumbnailUrl,
      };
    } catch (e) {
      print('Error uploading photo with thumbnail: $e');
      rethrow;
    }
  }

  /// Método de inicialización para la inyección asíncrona.
  Future<CameraService> init() async {
    await initCamera();
    return this;
  }

  /// Limpia recursos si es necesario.
  void dispose() {
    // Implementa la limpieza de recursos si es requerido.
  }
}

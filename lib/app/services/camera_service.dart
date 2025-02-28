import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:povo/app/services/storage_service.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

class CameraService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  final Rx<CameraState?> cameraState = Rx<CameraState?>(null);
  final RxBool hasPermission = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isFlashOn = false.obs;

  // Camera filters
  // Camera filters
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

  Future<void> initCamera() async {
    await _checkAndRequestPermissions();
    isInitialized.value = true;
  }

  Future<void> _checkAndRequestPermissions() async {
    final cameraPermission = await Permission.camera.status;
    final microphonePermission = await Permission.microphone.status;

    if (!cameraPermission.isGranted) {
      await Permission.camera.request();
    }

    if (!microphonePermission.isGranted) {
      await Permission.microphone.request();
    }

    hasPermission.value = await Permission.camera.isGranted;
  }

  void toggleCamera() {
    isFrontCamera.value = !isFrontCamera.value;
  }

  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
  }

  void setFilter(AwesomeFilter filter) {
    currentFilter.value = filter;
  }

  Future<String> takePicture() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final path = '${tempDir.path}/$fileName';

      // Tomar la foto usando CamerAwesome - método correcto
      String? filePath;

      await cameraState.value?.when(
        onPhotoMode: (photoState) async {
          // Aquí está el método correcto para tomar una foto
          final captureRequest = await photoState.takePhoto();
          filePath = captureRequest.path;
        },
        onVideoMode: (_) => null,
        onVideoRecordingMode: (_) => null,
        onPreparingCamera: (_) => null,
      );

      if (filePath == null) {
        throw Exception('Failed to take picture');
      }

      // Aplicar filtro a la imagen
      File processedFile = File(filePath!);

      if (currentFilter.value != AwesomeFilter.None) {
        // Aplicar el filtro seleccionado a la imagen
        final img =
            await decodeImageFromList(await processedFile.readAsBytes());
        final filteredImg = await applyFilterToImage(img, currentFilter.value);

        // Guardar la imagen filtrada
        final filteredFile = File('${tempDir.path}/filtered_$fileName');
        await filteredFile.writeAsBytes(filteredImg);
        processedFile = filteredFile;
      }

      // Comprimir la imagen y generar thumbnail
      final compressedFile = await compressImage(processedFile.path, path);

      return compressedFile.path;
    } catch (e) {
      print('Error taking picture: $e');
      rethrow;
    }
  }

// Función para aplicar un filtro a una imagen
  Future<Uint8List> applyFilterToImage(
      ui.Image image, AwesomeFilter filter) async {
    // Crear un canvas para dibujar la imagen
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Obtener el tamaño de la imagen
    final size = Size(image.width.toDouble(), image.height.toDouble());

    // Aplicar el filtro como un ColorFilter
    final paint = Paint()..colorFilter = filter.preview;

    // Dibujar la imagen con el filtro aplicado
    canvas.drawImage(image, Offset.zero, paint);

    // Capturar el resultado
    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to apply filter to image');
    }

    return byteData.buffer.asUint8List();
  }

  Future<File> compressImage(String inputPath, String outputPath) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      inputPath,
      outputPath,
      quality: 85,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return File(result.path);
  }

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
        throw Exception('Failed to generate thumbnail');
      }

      return result.path;
    } catch (e) {
      print('Error generating thumbnail: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> uploadPhotoWithThumbnail(
      String photoPath, String eventId) async {
    try {
      // Generate thumbnail
      final thumbnailPath = await generateThumbnail(photoPath);

      // Generate unique filenames
      final fileName = 'event_$eventId/${const Uuid().v4()}.jpg';
      final thumbnailFileName = 'event_$eventId/thumb_${const Uuid().v4()}.jpg';

      // Upload both files to Firebase Storage
      final photoUrl =
          await _storageService.uploadFile(photoPath, 'photos/$fileName');
      final thumbnailUrl = await _storageService.uploadFile(
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

  // Camera settings methods
  CameraAspectRatios getCurrentAspectRatio() {
    return CameraAspectRatios.ratio_4_3;
  }

  void setAspectRatio(CameraAspectRatios ratio) {
    // This would be implemented to change the camera's aspect ratio
    // In a real app, this would interact with CamerAwesome's API
  }

  double getZoomLevel() {
    return 1.0; // Default zoom level
  }

  void setZoomLevel(double zoom) {
    // This would adjust zoom using CamerAwesome's API
  }

  // Camera configuration
  SensorConfig getSensorConfig() {
    return SensorConfig.single(
      flashMode: isFlashOn.value ? FlashMode.always : FlashMode.none,
      aspectRatio: getCurrentAspectRatio(),
      sensor: Sensor.position(
          isFrontCamera.value ? SensorPosition.front : SensorPosition.back),
    );
  }

  // Clean up resources
  void dispose() {
    // Clean up any resources if needed
  }

  // Initialize service
  Future<CameraService> init() async {
    await initCamera();
    return this;
  }
}

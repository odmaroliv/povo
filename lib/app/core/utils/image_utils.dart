// image_utils.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  // Comprimir imagen
  static Future<File> compressImage(File file, {int quality = 85}) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final fileName = const Uuid().v4();
    final targetPath = "$path/$fileName.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );

    return File(result!.path);
  }

  // Generar una miniatura
  static Future<File> generateThumbnail(
    File file, {
    int quality = 70,
    int maxWidth = 300,
    int maxHeight = 300,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final fileName = "thumb_${const Uuid().v4()}.jpg";
    final targetPath = "$path/$fileName";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
    );

    return File(result!.path);
  }

  // Recortar una imagen a dimensiones específicas
  static Future<File> cropToAspectRatio(File file, double aspectRatio) async {
    // Este sería implementado con alguna librería de manipulación de imágenes
    // Por ahora, devolvemos la imagen original
    return file;
  }

  // Obtener las dimensiones de una imagen
  static Future<Size> getImageDimensions(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  // Calcular el tamaño de archivo en MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
}

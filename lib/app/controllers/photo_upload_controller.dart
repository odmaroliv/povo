import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:povo/app/data/repositories/photo_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/image_picker_service.dart';

class PhotoUploadController extends GetxController {
  final PhotoRepository _photoRepository = Get.find<PhotoRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Estado de la subida
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  // Lista de imágenes seleccionadas y campo de descripción
  RxList<File> selectedImages = <File>[].obs;
  TextEditingController captionController = TextEditingController();

  // Obtiene el userId desde AuthService
  String get userId => _authService.userId!;

  /// Selecciona múltiples imágenes de la galería.
  Future<void> pickMultipleImages() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final List<XFile> images = await _imagePickerService.pickMultipleImages();
      if (images.isNotEmpty) {
        selectedImages
            .assignAll(images.map((xfile) => File(xfile.path)).toList());
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al seleccionar imágenes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Sube todas las imágenes seleccionadas asociándolas a un evento.
  Future<void> uploadMultipleImages(String eventId) async {
    if (selectedImages.isEmpty) {
      Get.snackbar("Error", "No se han seleccionado imágenes.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Iterar sobre cada imagen y subirla usando el método de tu PhotoRepository.
      // Se asume que PhotoRepository.uploadPhoto() está implementado.
      for (final File image in selectedImages) {
        await _photoRepository.uploadPhoto(
          photoPath: image.path,
          eventId: eventId,
          userId: userId,
          caption: captionController.text.trim(),
          filter: {}, // Puedes agregar información sobre filtro si corresponde.
        );
      }

      Get.snackbar("Éxito", "Las imágenes se subieron correctamente.",
          snackPosition: SnackPosition.BOTTOM);

      // Limpiar estado
      selectedImages.clear();
      captionController.clear();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al subir las imágenes: $e';
      Get.snackbar("Error", errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    captionController.dispose();
    super.onClose();
  }
}

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Permite seleccionar una imagen de la galería con configuraciones robustas.
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 90,
      );
      return image;
    } catch (e) {
      rethrow;
    }
  }

  /// Selecciona múltiples imágenes desde la galería.
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 90,
      );
      return images ?? [];
    } catch (e) {
      rethrow;
    }
  }
}

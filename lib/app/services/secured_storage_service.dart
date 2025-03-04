import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';

class SecuredStorageService extends GetxService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Inicializar el servicio
  Future<SecuredStorageService> init() async {
    return this;
  }

  // Obtener URL segura para una sola foto
  Future<String> getSecurePhotoUrl(String eventId, String photoPath, {bool isThumb = false}) async {
    try {
      final result = await _functions.httpsCallable('getSecureEventPhotoUrl').call({
        'eventId': eventId,
        'photoPath': photoPath,
        'isThumb': isThumb
      });
      
      if (result.data != null && result.data['url'] != null) {
        return result.data['url'] as String;
      } else {
        throw Exception('URL no disponible');
      }
    } catch (e) {
      print('Error obteniendo URL segura: $e');
      rethrow;
    }
  }

  // Obtener múltiples URLs en una sola llamada (optimización)
  Future<Map<String, String>> getMultiplePhotoUrls(
      String eventId, List<Map<String, dynamic>> photoPaths) async {
    try {
      final result = await _functions.httpsCallable('getEventPhotosUrls').call({
        'eventId': eventId,
        'photoPaths': photoPaths
      });
      
      // Procesar resultados
      final Map<String, String> photoUrls = {};
      if (result.data != null && result.data['urls'] != null) {
        for (var item in result.data['urls']) {
          if (item['url'] != null) {
            final key = '${item['photoId']}_${item['isThumb'] ? 'thumb' : 'full'}';
            photoUrls[key] = item['url'];
          }
        }
      }
      
      return photoUrls;
    } catch (e) {
      print('Error obteniendo múltiples URLs: $e');
      rethrow;
    }
  }
}
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Reference getters
  Reference get rootRef => _storage.ref();
  Reference get photosRef => _storage.ref().child('photos');
  Reference get thumbnailsRef => _storage.ref().child('thumbnails');
  Reference get profileImagesRef => _storage.ref().child('profile_images');
  Reference get eventCoversRef => _storage.ref().child('event_covers');

  // Upload methods
  Future<String> uploadFile(String filePath, String storagePath) async {
    try {
      final file = File(filePath);

      // Verificar si el archivo existe
      if (!await file.exists()) {
        throw Exception('El archivo no existe: $filePath');
      }

      // Asegurarse de que el directorio exista creando la ruta completa
      // Firebase Storage no necesita crear directorios explícitamente,
      // pero el enfoque de carga debe ser correcto

      final ref = _storage.ref().child(storagePath);

      print('Intentando subir a: $storagePath');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: $progress');
      });

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);

      if (snapshot.state == TaskState.success) {
        // Get the download URL
        final downloadUrl = await ref.getDownloadURL();
        print('Archivo subido exitosamente a: $storagePath');
        return downloadUrl;
      } else {
        throw Exception('Error subiendo archivo: ${snapshot.state}');
      }
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(String filePath, String userId) async {
    final extension = path.extension(filePath);
    final fileName = 'profile_$userId$extension';

    // Asegúrate de que el directorio "profile_images" exista
    try {
      await _storage.ref().child('profile_images').list();
    } catch (e) {
      // El directorio no existe, intentamos crearlo con un archivo placeholder
      await _storage.ref().child('profile_images/.placeholder').putString('');
    }

    return uploadFile(filePath, 'profile_images/$fileName');
  }

  Future<String> uploadEventCover(String filePath, String eventId) async {
    final extension = path.extension(filePath);
    final fileName = 'event_$eventId$extension';

    // Asegúrate de que el directorio "event_covers" exista
    try {
      await _storage.ref().child('event_covers').list();
    } catch (e) {
      await _storage.ref().child('event_covers/.placeholder').putString('');
    }

    return uploadFile(filePath, 'event_covers/$fileName');
  }

  Future<String> uploadEventPhoto(String filePath, String eventId) async {
    final extension = path.extension(filePath);
    final fileName = '${const Uuid().v4()}$extension';
    final eventPath = 'photos/event_$eventId';

    // Asegúrate de que el directorio exista
    try {
      await _storage.ref().child('photos').list();
    } catch (e) {
      await _storage.ref().child('photos/.placeholder').putString('');
    }

    try {
      await _storage.ref().child(eventPath).list();
    } catch (e) {
      await _storage.ref().child('$eventPath/.placeholder').putString('');
    }

    return uploadFile(filePath, '$eventPath/$fileName');
  }

  // Para usar con el método uploadPhotoWithThumbnail
  Future<String> uploadPhotoToPath(String filePath, String path) async {
    // Extraer los componentes del path
    final components = path.split('/');
    String currentPath = '';

    // Intentar crear cada nivel del path
    for (int i = 0; i < components.length - 1; i++) {
      if (components[i].isNotEmpty) {
        currentPath += '${currentPath.isEmpty ? '' : '/'}${components[i]}';
        try {
          await _storage.ref().child(currentPath).list();
        } catch (e) {
          await _storage.ref().child('$currentPath/.placeholder').putString('');
        }
      }
    }

    return uploadFile(filePath, path);
  }

  // Delete methods
  Future<void> deleteFile(String storageUrl) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  Future<void> deleteEventPhotos(String eventId) async {
    try {
      final ref = photosRef.child('event_$eventId');

      try {
        final result = await ref.listAll();

        for (var item in result.items) {
          await item.delete();
        }

        for (var prefix in result.prefixes) {
          final subResult = await prefix.listAll();
          for (var item in subResult.items) {
            await item.delete();
          }
        }
      } catch (e) {
        // Si el directorio no existe, no hay nada que eliminar
        print('No se encontraron fotos para eliminar: $e');
      }
    } catch (e) {
      print('Error deleting event photos: $e');
      rethrow;
    }
  }

  // Get URLs
  Future<List<String>> getEventPhotoUrls(String eventId) async {
    try {
      final ref = photosRef.child('event_$eventId');

      try {
        final result = await ref.listAll();

        final urls = <String>[];
        for (var item in result.items) {
          final url = await item.getDownloadURL();
          urls.add(url);
        }

        return urls;
      } catch (e) {
        // Si el directorio no existe, devolver una lista vacía
        print('No se encontraron fotos: $e');
        return [];
      }
    } catch (e) {
      print('Error getting event photo URLs: $e');
      rethrow;
    }
  }
}

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
      final ref = _storage.ref().child(storagePath);

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
      await uploadTask;

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(String filePath, String userId) async {
    final extension = path.extension(filePath);
    final fileName = 'profile_$userId$extension';
    return uploadFile(filePath, 'profile_images/$fileName');
  }

  Future<String> uploadEventCover(String filePath, String eventId) async {
    final extension = path.extension(filePath);
    final fileName = 'event_$eventId$extension';
    return uploadFile(filePath, 'event_covers/$fileName');
  }

  Future<String> uploadEventPhoto(String filePath, String eventId) async {
    final extension = path.extension(filePath);
    final fileName = '${const Uuid().v4()}$extension';
    return uploadFile(filePath, 'photos/event_$eventId/$fileName');
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
      print('Error deleting event photos: $e');
      rethrow;
    }
  }

  // Get URLs
  Future<List<String>> getEventPhotoUrls(String eventId) async {
    try {
      final ref = photosRef.child('event_$eventId');
      final result = await ref.listAll();

      final urls = <String>[];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print('Error getting event photo URLs: $e');
      rethrow;
    }
  }

  // Initialize service
  Future<StorageService> init() async {
    // You can add initialization code here if needed
    return this;
  }
}

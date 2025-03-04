import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:povo/app/services/camera_service.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/storage_service.dart';

class PhotoRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final StorageService _storageService = Get.find<StorageService>();
  final CameraService _cameraService = Get.find<CameraService>();

  // Collection reference
  CollectionReference get photosCollection => _firebaseService.photosCollection;

  // Upload a new photo
  Future<PhotoModel> uploadPhoto({
    required String photoPath,
    required String eventId,
    required String userId,
    String? caption,
    List<String> tags = const [],
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? filter,
  }) async {
    try {
      // Generate a unique ID for the photo
      final docRef = photosCollection.doc();
      final photoId = docRef.id;

      // Upload the photo and thumbnail to storage
      final urls =
          await _cameraService.uploadPhotoWithThumbnail(photoPath, eventId);

      // Create the photo model
      final photo = PhotoModel(
        id: photoId,
        eventId: eventId,
        userId: userId,
        url: urls['photoUrl']!,
        thumbnailUrl: urls['thumbnailUrl']!,
        status: 'pending', // Default status for new photos
        capturedAt: DateTime.now(),
        uploadedAt: DateTime.now(),
        caption: caption,
        tags: tags,
        metadata: metadata,
        filter: filter,
      );

      // Save to Firestore
      await docRef.set(photo.toJson());

      // Update the event document to include this photo ID
      await _firebaseService.eventsCollection.doc(eventId).update({
        'photoIds': FieldValue.arrayUnion([photoId]),
      });

      return photo;
    } catch (e) {
      print('Error uploading photo: $e');
      rethrow;
    }
  }

  // Get a single photo by ID
  Future<PhotoModel?> getPhoto(String photoId) async {
    try {
      final doc = await photosCollection.doc(photoId).get();

      if (doc.exists) {
        return PhotoModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting photo: $e');
      rethrow;
    }
  }

  // Update a photo
  Future<void> updatePhoto(PhotoModel photo) async {
    try {
      await photosCollection.doc(photo.id).update(photo.toJson());
    } catch (e) {
      print('Error updating photo: $e');
      rethrow;
    }
  }

  // Delete a photo
  Future<void> deletePhoto(String photoId) async {
    try {
      // Get the photo first
      final photo = await getPhoto(photoId);

      if (photo != null) {
        // Delete the photo from storage
        await _storageService.deleteFile(photo.url);

        // Delete the thumbnail from storage
        await _storageService.deleteFile(photo.thumbnailUrl);

        // Remove the photo ID from the event document
        await _firebaseService.eventsCollection.doc(photo.eventId).update({
          'photoIds': FieldValue.arrayRemove([photoId]),
        });

        // Delete the photo document
        await photosCollection.doc(photoId).delete();
      }
    } catch (e) {
      print('Error deleting photo: $e');
      rethrow;
    }
  }

  // Approve a photo
  Future<void> approvePhoto(String photoId) async {
    try {
      await photosCollection.doc(photoId).update({
        'status': 'approved',
      });
    } catch (e) {
      print('Error approving photo: $e');
      rethrow;
    }
  }

  // Reject a photo
  Future<void> rejectPhoto(String photoId) async {
    try {
      await photosCollection.doc(photoId).update({
        'status': 'rejected',
      });
    } catch (e) {
      print('Error rejecting photo: $e');
      rethrow;
    }
  }

  // Like a photo
  Future<void> likePhoto(String photoId, String userId) async {
    try {
      await photosCollection.doc(photoId).update({
        'likedByUserIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error liking photo: $e');
      rethrow;
    }
  }

  // Unlike a photo
  Future<void> unlikePhoto(String photoId, String userId) async {
    try {
      await photosCollection.doc(photoId).update({
        'likedByUserIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error unliking photo: $e');
      rethrow;
    }
  }

  // Get all photos for an event
  Future<List<PhotoModel>> getEventPhotos(String eventId,
      {String? status}) async {
    try {
      Query query = photosCollection.where('eventId', isEqualTo: eventId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => PhotoModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting event photos: $e');
      rethrow;
    }
  }

  // Stream of all photos for an event
  Stream<List<PhotoModel>> eventPhotosStream(String eventId, {String? status}) {
    Query query = photosCollection
        .where('eventId', isEqualTo: eventId)
        .orderBy('uploadedAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => PhotoModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Stream of pending photos for moderation
  Stream<List<PhotoModel>> pendingPhotosStream(String eventId) {
    return photosCollection
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'pending')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                PhotoModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get photos by user
  Future<List<PhotoModel>> getUserPhotos(String userId,
      {List<String>? eventIds}) async {
    try {
      Query query = photosCollection.where('userId', isEqualTo: userId);

      if (eventIds != null && eventIds.isNotEmpty) {
        query = query.where('eventId', whereIn: eventIds);
      }

      final snapshot =
          await query.orderBy('uploadedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => PhotoModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user photos: $e');
      rethrow;
    }
  }

  // Add caption to photo
  Future<void> addCaption(String photoId, String caption) async {
    try {
      await photosCollection.doc(photoId).update({
        'caption': caption,
      });
    } catch (e) {
      print('Error adding caption: $e');
      rethrow;
    }
  }
}

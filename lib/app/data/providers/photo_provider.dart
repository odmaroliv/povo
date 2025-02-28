// photo_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:povo/app/data/models/photo_model.dart';

class PhotoProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección de fotos
  CollectionReference get photosCollection => _firestore.collection('photos');

  // Obtener una foto por ID
  Future<DocumentSnapshot> getPhoto(String photoId) {
    return photosCollection.doc(photoId).get();
  }

  // Obtener fotos por evento
  Future<QuerySnapshot> getPhotosByEvent(String eventId, {String? status}) {
    Query query = photosCollection.where('eventId', isEqualTo: eventId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.orderBy('uploadedAt', descending: true).get();
  }

  // Crear una foto
  Future<DocumentReference> createPhoto(Map<String, dynamic> photoData) {
    return photosCollection.add(photoData);
  }

  // Actualizar una foto
  Future<void> updatePhoto(String photoId, Map<String, dynamic> photoData) {
    return photosCollection.doc(photoId).update(photoData);
  }

  // Eliminar una foto
  Future<void> deletePhoto(String photoId) {
    return photosCollection.doc(photoId).delete();
  }

  // Stream de fotos por evento
  Stream<QuerySnapshot> photosStreamByEvent(String eventId, {String? status}) {
    Query query = photosCollection.where('eventId', isEqualTo: eventId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.orderBy('uploadedAt', descending: true).snapshots();
  }
}

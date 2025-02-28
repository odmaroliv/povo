import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:povo/app/data/models/event_model.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:povo/app/data/models/user_model.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth
  User? get currentUser => _auth.currentUser;
  Stream<User?> get userChanges => _auth.userChanges();

  // Collections references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get eventsCollection => _firestore.collection('events');
  CollectionReference get photosCollection => _firestore.collection('photos');

  // Storage references
  Reference get photosStorageRef => _storage.ref().child('photos');

  // Auth methods
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'signin-failed',
        message: 'No se pudo iniciar sesión: ${e.toString()}',
      );
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'signup-failed',
        message: 'No se pudo crear la cuenta: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // User methods
  Future<void> createUserProfile(UserModel user) async {
    await usersCollection.doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<UserModel?> userProfileStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Event methods
  Future<String> createEvent(EventModel event) async {
    final docRef = await eventsCollection.add(event.toJson());
    return docRef.id;
  }

  Future<void> updateEvent(EventModel event) async {
    await eventsCollection.doc(event.id).update(event.toJson());
  }

  Future<EventModel?> getEvent(String eventId) async {
    final doc = await eventsCollection.doc(eventId).get();
    if (doc.exists) {
      return EventModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<EventModel?> eventStream(String eventId) {
    return eventsCollection.doc(eventId).snapshots().map((doc) {
      if (doc.exists) {
        return EventModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Stream<List<EventModel>> userEventsStream(String userId) {
    return eventsCollection.where('hostId', isEqualTo: userId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                EventModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<EventModel>> participatedEventsStream(String userId) {
    return eventsCollection
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                EventModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Photo methods
  Future<String> addPhoto(PhotoModel photo) async {
    final docRef = await photosCollection.add(photo.toJson());
    return docRef.id;
  }

  Future<void> updatePhoto(PhotoModel photo) async {
    await photosCollection.doc(photo.id).update(photo.toJson());
  }

  Future<List<PhotoModel>> getEventPhotos(String eventId,
      {bool onlyApproved = false}) async {
    Query query = photosCollection.where('eventId', isEqualTo: eventId);

    if (onlyApproved) {
      query = query.where('status', isEqualTo: 'approved');
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PhotoModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<PhotoModel>> eventPhotosStream(String eventId,
      {bool onlyApproved = false}) {
    Query query = photosCollection.where('eventId', isEqualTo: eventId);

    if (onlyApproved) {
      query = query.where('status', isEqualTo: 'approved');
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => PhotoModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Storage methods
  Future<String> uploadPhoto(String path, String fileName) async {
    final ref = photosStorageRef.child(fileName);
    final uploadTask = await ref.putFile(File(path));
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deletePhoto(String storageUrl) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

  // Initialize service
  Future<FirebaseService> init() async {
    // You can add initialization code here if needed
    return this;
  }
}

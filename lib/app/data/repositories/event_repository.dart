import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:povo/app/data/models/event_model.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class EventRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Collection reference
  CollectionReference get eventsCollection => _firebaseService.eventsCollection;

  // Create a new event
  Future<EventModel> createEvent({
    required String name,
    required String hostId,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    String? coverImagePath,
    String? locationName,
    GeoPoint? locationCoordinates,
    bool requiresModeration = true,
    Map<String, dynamic>? settings,
  }) async {
    try {
      // Generate a unique join code
      final joinCode = _generateJoinCode();

      // Create the event document ID
      final docRef = eventsCollection.doc();
      final String eventId = docRef.id;

      // Upload cover image if provided
      String? coverImageUrl;
      if (coverImagePath != null) {
        coverImageUrl =
            await _storageService.uploadEventCover(coverImagePath, eventId);
      }

      // Create event model
      final EventModel event = EventModel(
        id: eventId,
        name: name,
        hostId: hostId,
        description: description,
        startDate: startDate,
        endDate: endDate,
        coverImage: coverImageUrl,
        locationName: locationName,
        locationCoordinates: locationCoordinates,
        requiresModeration: requiresModeration,
        joinCode: joinCode,
        createdAt: DateTime.now(),
        settings: settings,
      );

      // Save to Firestore
      await docRef.set(event.toJson());

      // Update user's hosted events
      await _firebaseService.usersCollection.doc(hostId).update({
        'hostedEventIds': FieldValue.arrayUnion([eventId]),
      });

      return event;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  // Update an existing event
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      await eventsCollection.doc(event.id).update(event.toJson());
      return event;
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  // Get a single event by ID
  Future<EventModel?> getEvent(String eventId) async {
    try {
      final doc = await eventsCollection.doc(eventId).get();

      if (doc.exists) {
        return EventModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting event: $e');
      rethrow;
    }
  }

  // Get a single event by join code
  Future<EventModel?> getEventByJoinCode(String joinCode) async {
    try {
      final querySnapshot = await eventsCollection
          .where('joinCode', isEqualTo: joinCode)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return EventModel.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting event by join code: $e');
      rethrow;
    }
  }

  // Get events created by a user
  Future<List<EventModel>> getHostedEvents(String userId) async {
    try {
      final querySnapshot = await eventsCollection
          .where('hostId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting hosted events: $e');
      rethrow;
    }
  }

  // Get events in which a user participated
  Future<List<EventModel>> getParticipatedEvents(String userId) async {
    try {
      final querySnapshot = await eventsCollection
          .where('participantIds', arrayContains: userId)
          .orderBy('startDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting participated events: $e');
      rethrow;
    }
  }

  // Stream of a single event
  Stream<EventModel?> eventStream(String eventId) {
    return eventsCollection.doc(eventId).snapshots().map((doc) {
      if (doc.exists) {
        return EventModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Stream of hosted events
  Stream<List<EventModel>> hostedEventsStream(String userId) {
    return eventsCollection
        .where('hostId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                EventModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Stream of participated events
  Stream<List<EventModel>> participatedEventsStream(String userId) {
    return eventsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                EventModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Join an event
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      // Add user to event's participants
      await eventsCollection.doc(eventId).update({
        'participantIds': FieldValue.arrayUnion([userId]),
      });

      // Add event to user's participated events
      await _firebaseService.usersCollection.doc(userId).update({
        'participatedEventIds': FieldValue.arrayUnion([eventId]),
      });
    } catch (e) {
      print('Error joining event: $e');
      rethrow;
    }
  }

  // Leave an event
  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      // Remove user from event's participants
      await eventsCollection.doc(eventId).update({
        'participantIds': FieldValue.arrayRemove([userId]),
      });

      // Remove event from user's participated events
      await _firebaseService.usersCollection.doc(userId).update({
        'participatedEventIds': FieldValue.arrayRemove([eventId]),
      });
    } catch (e) {
      print('Error leaving event: $e');
      rethrow;
    }
  }

  // Change event status
  Future<void> changeEventStatus(String eventId, String status) async {
    try {
      await eventsCollection.doc(eventId).update({
        'status': status,
      });
    } catch (e) {
      print('Error changing event status: $e');
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId, String hostId) async {
    try {
      final event = await getEvent(eventId);

      if (event != null) {
        // Delete cover image if exists
        if (event.coverImage != null) {
          await _storageService.deleteFile(event.coverImage!);
        }

        // Delete event photos
        await _storageService.deleteEventPhotos(eventId);

        // Remove event from host's hostedEventIds
        await _firebaseService.usersCollection.doc(hostId).update({
          'hostedEventIds': FieldValue.arrayRemove([eventId]),
        });

        // Remove event from all participants' participatedEventIds
        for (String participantId in event.participantIds) {
          await _firebaseService.usersCollection.doc(participantId).update({
            'participatedEventIds': FieldValue.arrayRemove([eventId]),
          });
        }

        // Delete photos subcollection (if any)
        final photosSnapshot = await _firebaseService.photosCollection
            .where('eventId', isEqualTo: eventId)
            .get();

        for (var doc in photosSnapshot.docs) {
          await doc.reference.delete();
        }

        // Finally delete the event document
        await eventsCollection.doc(eventId).delete();
      }
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  // Regenerate join code
  Future<String> regenerateJoinCode(String eventId) async {
    try {
      final joinCode = _generateJoinCode();

      await eventsCollection.doc(eventId).update({
        'joinCode': joinCode,
      });

      return joinCode;
    } catch (e) {
      print('Error regenerating join code: $e');
      rethrow;
    }
  }

// Update event moderation flag
  Future<void> updateEventModeration(
      String eventId, bool requiresModeration) async {
    try {
      await eventsCollection.doc(eventId).update({
        'requiresModeration': requiresModeration,
      });
    } catch (e) {
      print('Error updating event moderation: $e');
      rethrow;
    }
  }

  // Generate a unique 6-character join code
  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = const Uuid().v4();
    final code = List.generate(6, (index) {
      final randomIndex =
          (random.codeUnitAt(index % random.length) % chars.length);
      return chars[randomIndex];
    }).join();

    return code;
  }
}

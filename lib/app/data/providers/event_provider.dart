// event_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:povo/app/data/models/event_model.dart';

class EventProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección de eventos
  CollectionReference get eventsCollection => _firestore.collection('events');

  // Obtener un evento por ID
  Future<DocumentSnapshot> getEvent(String eventId) {
    return eventsCollection.doc(eventId).get();
  }

  // Obtener eventos por anfitrión
  Future<QuerySnapshot> getEventsByHost(String hostId) {
    return eventsCollection
        .where('hostId', isEqualTo: hostId)
        .orderBy('startDate', descending: true)
        .get();
  }

  // Obtener eventos por participante
  Future<QuerySnapshot> getEventsByParticipant(String userId) {
    return eventsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('startDate', descending: true)
        .get();
  }

  // Crear un evento
  Future<DocumentReference> createEvent(Map<String, dynamic> eventData) {
    return eventsCollection.add(eventData);
  }

  // Actualizar un evento
  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData) {
    return eventsCollection.doc(eventId).update(eventData);
  }

  // Eliminar un evento
  Future<void> deleteEvent(String eventId) {
    return eventsCollection.doc(eventId).delete();
  }

  // Stream de un evento
  Stream<DocumentSnapshot> eventStream(String eventId) {
    return eventsCollection.doc(eventId).snapshots();
  }

  // Stream de eventos por anfitrión
  Stream<QuerySnapshot> eventsStreamByHost(String hostId) {
    return eventsCollection
        .where('hostId', isEqualTo: hostId)
        .orderBy('startDate', descending: true)
        .snapshots();
  }

  // Stream de eventos por participante
  Stream<QuerySnapshot> eventsStreamByParticipant(String userId) {
    return eventsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('startDate', descending: true)
        .snapshots();
  }
}

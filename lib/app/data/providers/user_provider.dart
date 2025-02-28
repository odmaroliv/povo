// user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:povo/app/data/models/user_model.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección de usuarios
  CollectionReference get usersCollection => _firestore.collection('users');

  // Obtener un usuario por ID
  Future<DocumentSnapshot> getUser(String userId) {
    return usersCollection.doc(userId).get();
  }

  // Obtener usuario por email
  Future<QuerySnapshot> getUserByEmail(String email) {
    return usersCollection.where('email', isEqualTo: email).limit(1).get();
  }

  // Crear un usuario
  Future<void> createUser(String userId, Map<String, dynamic> userData) {
    return usersCollection.doc(userId).set(userData);
  }

  // Actualizar un usuario
  Future<void> updateUser(String userId, Map<String, dynamic> userData) {
    return usersCollection.doc(userId).update(userData);
  }

  // Eliminar un usuario
  Future<void> deleteUser(String userId) {
    return usersCollection.doc(userId).delete();
  }

  // Stream de un usuario
  Stream<DocumentSnapshot> userStream(String userId) {
    return usersCollection.doc(userId).snapshots();
  }

  // Obtener múltiples usuarios por IDs
  Future<QuerySnapshot> getUsersByIds(List<String> userIds) {
    // Firestore solo permite hasta 10 valores en una cláusula whereIn
    // Para listas más grandes, se deberían hacer múltiples consultas
    return usersCollection
        .where(FieldPath.documentId, whereIn: userIds.take(10).toList())
        .get();
  }
}

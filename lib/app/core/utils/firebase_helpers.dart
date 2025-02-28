// firebase_helpers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class FirebaseHelpers {
  // Convertir Timestamp a DateTime
  static DateTime timestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  // Convertir DateTime a Timestamp
  static Timestamp dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  // Paginar consultas de Firestore
  static Future<List<QueryDocumentSnapshot>> paginateQuery({
    required Query query,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query paginatedQuery = query.limit(limit);

    if (startAfter != null) {
      paginatedQuery = paginatedQuery.startAfterDocument(startAfter);
    }

    final QuerySnapshot snapshot = await paginatedQuery.get();
    return snapshot.docs;
  }

  // Transacción para incrementar/decrementar un contador
  static Future<void> updateCounter({
    required String collection,
    required String document,
    required String field,
    required int incrementBy,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore.runTransaction((transaction) async {
      final docRef = firestore.collection(collection).doc(document);
      final docSnapshot = await transaction.get(docRef);

      if (docSnapshot.exists) {
        final currentValue = docSnapshot.get(field) as int;
        transaction.update(docRef, {field: currentValue + incrementBy});
      }
    });
  }

  // Obtener documentos por lotes de IDs (útil cuando hay más de 10 IDs)
  static Future<List<DocumentSnapshot>> getBatchDocuments({
    required String collection,
    required List<String> ids,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final List<DocumentSnapshot> documents = [];

    // Firestore only allows 10 items in a whereIn clause
    final batches = <List<String>>[];
    for (var i = 0; i < ids.length; i += 10) {
      final end = (i + 10 < ids.length) ? i + 10 : ids.length;
      batches.add(ids.sublist(i, end));
    }

    for (final batch in batches) {
      final QuerySnapshot querySnapshot = await firestore
          .collection(collection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      documents.addAll(querySnapshot.docs);
    }

    return documents;
  }
}

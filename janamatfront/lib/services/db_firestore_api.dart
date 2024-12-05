import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add data to Firestore
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  // Get data from Firestore
  Stream<List<Map<String, dynamic>>> getData(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  // Update data in Firestore
  Future<void> updateData(
      String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Delete data from Firestore
  Future<void> deleteData(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }
}

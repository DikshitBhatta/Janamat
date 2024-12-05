import 'package:flutter/material.dart';
import 'db_firestore_api.dart';

class FirestoreProvider with ChangeNotifier {
  final FirestoreAPI _firestoreAPI = FirestoreAPI();

  // Add data to Firestore
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _firestoreAPI.addData(collection, data);
    notifyListeners();
  }

  // Get data from Firestore
  Stream<List<Map<String, dynamic>>> getData(String collection) {
    return _firestoreAPI.getData(collection);
  }

  // Update data in Firestore
  Future<void> updateData(
      String collection, String docId, Map<String, dynamic> data) async {
    await _firestoreAPI.updateData(collection, docId, data);
    notifyListeners();
  }

  // Delete data from Firestore
  Future<void> deleteData(String collection, String docId) async {
    await _firestoreAPI.deleteData(collection, docId);
    notifyListeners();
  }
}

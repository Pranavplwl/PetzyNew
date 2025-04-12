import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get petsCollection => _firestore.collection('pets');
  CollectionReference get usersCollection => _firestore.collection('users');

  // Add a new pet with auto-generated ID
  Future<String> addPet(Map<String, dynamic> petData) async {
    try {
      final docRef = petsCollection.doc();
      await docRef.set({
        ...petData,
        'id': docRef.id, // Ensure ID is stored in document
        'createdAt': FieldValue.serverTimestamp(), // Add server timestamp
      });
      return docRef.id; // Return the generated ID
    } catch (e) {
      debugPrint('Error adding pet: $e');
      rethrow;
    }
  }

  // Get all pets with pagination options
  Stream<QuerySnapshot> getPets({int? limit}) {
    var query = petsCollection.orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  // Get single pet with error handling
  Future<DocumentSnapshot> getPet(String petId) async {
    try {
      return await petsCollection.doc(petId).get();
    } catch (e) {
      debugPrint('Error getting pet $petId: $e');
      rethrow;
    }
  }

  // User operations
  Future<void> setUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(uid).set({
        ...userData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error setting user data: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await usersCollection.doc(uid).get();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      rethrow;
    }
  }

  Future<void> updateUserFavorites(
      String userId, List<String> favoritePetIds) async {
    try {
      await usersCollection.doc(userId).update({
        'favoritePetIds': favoritePetIds,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating favorites: $e');
      rethrow;
    }
  }
}

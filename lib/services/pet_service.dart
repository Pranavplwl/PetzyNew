import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:petzy/models/pet_model.dart';
import 'package:petzy/services/firestore_service.dart';

class PetService {
  final FirestoreService _firestoreService = FirestoreService();

  // Get all pets stream with optional filtering
  Stream<List<Pet>> getPetsStream({String? typeFilter}) {
    return _firestoreService.getPets().map((snapshot) {
      return snapshot.docs
          .where((doc) => typeFilter == null || doc['type'] == typeFilter)
          .map((doc) => Pet.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Get a single pet with error handling
  Future<Pet> getPet(String petId) async {
    try {
      final doc = await _firestoreService.getPet(petId);
      if (!doc.exists) {
        throw Exception('Pet not found');
      }
      return Pet.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('Error getting pet $petId: $e');
      rethrow;
    }
  }

  // Add a new pet and return its ID
  Future<String> addPet(Pet pet) async {
    try {
      final docRef = _firestoreService.petsCollection.doc();
      final petData = pet.toMap()
        ..addAll({
          'id': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'ownerId': pet.ownerId, // Ensure ownerId is included
        });

      debugPrint('[PetService] Saving pet data: $petData');
      await docRef.set(petData);
      debugPrint('[PetService] Pet saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[PetService ERROR] $e');
      throw Exception('Failed to save pet: ${e.toString()}');
    }
  }

  // Update an existing pet
  Future<void> updatePet(Pet pet) async {
    try {
      if (pet.id.isEmpty) throw Exception('Pet ID is required for update');
      await _firestoreService.petsCollection.doc(pet.id).update({
        ...pet.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating pet ${pet.id}: $e');
      rethrow;
    }
  }

  // Delete a pet
  Future<void> deletePet(String petId) async {
    try {
      await _firestoreService.petsCollection.doc(petId).delete();
    } catch (e) {
      debugPrint('Error deleting pet $petId: $e');
      rethrow;
    }
  }
}

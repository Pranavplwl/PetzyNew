import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:petzy/models/pet_model.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _favoritePetIds = [];
  List<Pet> _favoritePets = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialLoad = false;

  List<String> get favoritePetIds => List.unmodifiable(_favoritePetIds);
  List<Pet> get favoritePets => List.unmodifiable(_favoritePets);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialLoad => _hasInitialLoad;

  bool isFavorite(String petId) => _favoritePetIds.contains(petId);

  Future<void> initialize(String uid) async {
    if (!_hasInitialLoad) {
      await loadFavorites();
      _hasInitialLoad = true;
    }
    _setupFavoritesListener();
  }

  void _setupFavoritesListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      _favoritePetIds = snapshot.docs.map((doc) => doc.id).toList();
      _loadFavoritePets();
      notifyListeners();
    });
  }

  Future<void> loadFavorites() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _favoritePetIds = [];
        _favoritePets = [];
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _favoritePetIds = snapshot.docs.map((doc) => doc.id).toList();
      await _loadFavoritePets();
    } catch (e) {
      _error = 'Failed to load favorites: ${e.toString()}';
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavoritePets() async {
    try {
      if (_favoritePetIds.isEmpty) {
        _favoritePets = [];
        return;
      }

      _favoritePets = [];
      final petsSnapshot = await _firestore
          .collection('pets')
          .where(FieldPath.documentId, whereIn: _favoritePetIds)
          .get();

      _favoritePets = petsSnapshot.docs
          .map((doc) => Pet.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to load pet details: ${e.toString()}';
      debugPrint('Error loading favorite pets: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String petId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final wasFavorite = isFavorite(petId);
      final favoritesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(petId);

      if (wasFavorite) {
        await favoritesRef.delete();
      } else {
        await favoritesRef.set({
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _error = 'Failed to update favorite: ${e.toString()}';
      debugPrint('Error toggling favorite: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

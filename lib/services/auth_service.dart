import 'package:firebase_auth/firebase_auth.dart';
import 'package:petzy/models/user_model.dart';
import 'package:petzy/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Auth change user stream
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String name, String phone) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Create user document in Firestore
      await _firestoreService.setUserData(result.user!.uid, {
        'name': name,
        'email': email,
        'phone': phone,
        'address': '',
        'favoritePetIds': [],
      });

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user data
  Future<AppUser> getUserData(String uid) async {
    final doc = await _firestoreService.getUserData(uid);
    return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}

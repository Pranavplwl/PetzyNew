import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:petzy/models/activity_model.dart';

class ActivitiesProvider with ChangeNotifier {
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActivities() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('activities')
          .orderBy('createdAt', descending: true)
          .get();

      _activities =
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load activities: ${e.toString()}';
      debugPrint('Error loading activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify user is admin
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['isAdmin'] != true) {
        throw Exception('Only admins can add activities');
      }

      await FirebaseFirestore.instance.collection('activities').add({
        'title': activity.title,
        'description': activity.description,
        'imageUrl': activity.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadActivities(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add activity: ${e.toString()}';
      debugPrint('Error adding activity: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify user is admin
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['isAdmin'] != true) {
        throw Exception('Only admins can update activities');
      }

      await FirebaseFirestore.instance
          .collection('activities')
          .doc(activity.id)
          .update({
        'title': activity.title,
        'description': activity.description,
        'imageUrl': activity.imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadActivities(); // Refresh the list
    } catch (e) {
      _error = 'Failed to update activity: ${e.toString()}';
      debugPrint('Error updating activity: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify user is admin
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['isAdmin'] != true) {
        throw Exception('Only admins can delete activities');
      }

      await FirebaseFirestore.instance
          .collection('activities')
          .doc(activityId)
          .delete();

      await loadActivities(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete activity: ${e.toString()}';
      debugPrint('Error deleting activity: $e');
      notifyListeners();
      rethrow;
    }
  }
}

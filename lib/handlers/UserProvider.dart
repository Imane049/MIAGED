import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  // Getter to retrieve the userId from the userData map
  String? get userId => _userData != null ? _userData!['id'] : null;

  void setUserData(String userId, Map<String, dynamic> data) {
    _userData = {
      ...data,
      'id': userId,
    };

    print("setUserData called. _userData is now: $_userData");

    notifyListeners();
  }

  void clearUserData() {
    _userData = null;
    notifyListeners();
  }

  // Update Firestore with the current user data
  Future<void> saveUserData(Map<String, dynamic> updatedData) async {
    final currentUserId = userId;

    if (currentUserId == null) {
      throw Exception("User ID is not set");
    }

    try {
      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update(updatedData);

      // Update local user data
      _userData = {
        ...?_userData,
        ...updatedData,
      };

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to save data: $e");
    }
  }
}

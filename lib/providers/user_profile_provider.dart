import 'dart:io';

import 'package:flutter/material.dart';
import 'package:facesoft/API_services/user_api.dart';
import 'package:facesoft/model/user_profile_model.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserProfile(int userId) async {
    try {
      _setLoading(true);
      final userData = await UserService.getUserById(userId);
      print("API Response: $userData");
      if (userData['success'] == true && userData['data'] != null) {
        _userProfile = UserProfile.fromJson(userData['data']);
        _error = null;
      } else {
        _error = 'Invalid API response format';
      }
    } catch (e) {
      print("Error in fetchUserProfile: $e");
      _userProfile = null;
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile({
    required int userId,
    required Map<String, dynamic> updatedFields,
    File? profileImage,
  }) async {
    try {
      _setLoading(true);
      final response = await UserService.updateUserProfile(
        userId,
        updatedFields,
        profileImage: profileImage,
      );
      
      if (response['success'] == true) {
        // Refresh the user profile after successful update
        await fetchUserProfile(userId);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      print("Error in updateUserProfile: $e");
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      _setLoading(true);
      final success = await UserService.deleteUser(userId);
      if (success) {
        _userProfile = null;
        _error = null;
        return true;
      }
      _error = 'Failed to delete user';
      return false;
    } catch (e) {
      print("Error in deleteUser: $e");
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

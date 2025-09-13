import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class UserService {

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final response = await http.get(Uri.parse('${API_Data.user}/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data: ${response.statusCode}');
    }
  }

  static Future<bool> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('${API_Data.user}/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['success'] == true;
    } else {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }

  // Update user with only changed fields. If imageFile is provided, uses multipart.
  static Future<Map<String, dynamic>> updateUserProfile(
    int userId, 
    Map<String, dynamic> updatedFields, {
    File? profileImage,
  }) async {
    try {
      final uri = Uri.parse('${API_Data.user}/$userId');
      final request = http.MultipartRequest('PUT', uri);
      
      // Add all fields to the request
      updatedFields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add profile image if provided
      if (profileImage != null && await profileImage.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image', 
          profileImage.path,
        ));
      }
      
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      
      print("Update User Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return {'success': true, 'message': decoded['message']};
        } else {
          return {'success': false, 'message': 'Failed to update user profile'};
        }
      } else {
        return {'success': false, 'message': 'Failed to update user profile: ${response.statusCode}'};
      }
    } catch (e) {
      print("Exception caught: $e");
      return {'success': false, 'message': 'Exception: $e'};
    }
  }
}
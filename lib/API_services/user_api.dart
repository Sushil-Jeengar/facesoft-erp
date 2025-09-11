import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class UserService {

  static Future<List<int>> fetchUserIds() async {
    final response = await http.get(
      Uri.parse(API_Data.user),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final users = data['data'] as List<dynamic>;
        final ids = users.map((user) => user['id'] as int).toList();
        return ids;
      } else {
        throw Exception('Failed to load user data: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load user data: ${response.statusCode}');
    }
  }

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
  static Future<bool> updateUserProfilePartial(
    int userId,
    Map<String, dynamic> changedFields, {
    File? imageFile,
  }) async {
    final Uri url = Uri.parse('${API_Data.user}/$userId');

    try {
      http.Response response;
      if (imageFile != null) {
        final request = http.MultipartRequest('PUT', url);
        // Attach JSON fields as fields
        changedFields.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        request.files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));
        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(changedFields),
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (_) {
      rethrow;
    }
  }
}
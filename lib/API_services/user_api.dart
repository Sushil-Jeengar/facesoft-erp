import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:http/http.dart' as http;

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
}
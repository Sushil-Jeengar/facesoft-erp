import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/quality_model.dart';

class QualityApiService {
  static Future<List<Quality>?> fetchQualities() async {
    try {
      final response = await http.get(Uri.parse(API_Data.qualities));
      print("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          print("Parsed qualities data successfully");
          return (decoded['data'] as List)
              .map((json) => Quality.fromJson(json))
              .toList();
        } else {
          print("API responded with success=false or missing data");
          return [];
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception caught: $e");
      return null;
    }
  }


  static Future<bool> createQuality(Quality quality) async {
    try {
      final response = await http.post(
        Uri.parse(API_Data.qualities),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(quality.toJson()),
      );
      print("Create Quality Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['success'] == true;
      } else {
        print("HTTP Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception caught: $e");
      return false;
    }
  }

  static Future<bool> deleteQuality(int id) async {
    try {
      final response = await http.delete(Uri.parse('${API_Data.qualities}/$id'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['success'] == true;
      } else {
        print("HTTP Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception caught: $e");
      return false;
    }
  }


  static Future<bool> updateQuality(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('${API_Data.qualities}/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      print("Update Quality Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['success'] == true;
      } else {
        print("HTTP Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception caught: $e");
      return false;
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/parties_model.dart';
import 'package:http/http.dart' as http;

class PartiesApiService {
  static Future<List<Party>?> fetchParties() async {
    try {
      final response = await http.get(Uri.parse(API_Data.parties));
      print("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          print("Parsed parties data successfully");
          return (decoded['data'] as List)
              .map((json) => Party.fromJson(json))
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

  // Delete Party API
  static Future<bool> deleteParty(int partyId) async {
    try {
      final response = await http.delete(
        Uri.parse('${API_Data.parties}/$partyId'),
      );
      print("Delete Status Code: ${response.statusCode}");
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

  // Create Party API with Image Support
  static Future<Map<String, dynamic>> createParty(Party party, {File? imageFile}) async {
    try {
      final uri = Uri.parse(API_Data.parties);
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll(party.toJson().map((key, value) => MapEntry(key, value.toString())));
      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print("Create Party Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return {'success': true, 'data': decoded['data']};
        } else {
          return {'success': false, 'message': 'Failed to add party: ${response.statusCode}'};
        }
      } else {
        return {'success': false, 'message': 'Failed to add party: ${response.statusCode}'};
      }
    } catch (e) {
      print("Exception caught: $e");
      return {'success': false, 'message': 'Exception: $e'};
    }
  }

  // Update Party API with Image Support
  static Future<Map<String, dynamic>> updateParty(Party party, {File? imageFile}) async {
    try {
      if (party.id == null) {
        print("Update Party Error: party.id is null");
        return {'success': false, 'message': 'party.id is null'};
      }
      final uri = Uri.parse('${API_Data.parties}/${party.id}');
      final request = http.MultipartRequest('PUT', uri);
      request.fields.addAll(party.toJson().map((key, value) => MapEntry(key, value.toString())));
      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print("Update Party Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return {'success': true, 'message': decoded['message']};
        } else {
          return {'success': false, 'message': 'Failed to update party: ${response.statusCode}'};
        }
      } else {
        return {'success': false, 'message': 'Failed to update party: ${response.statusCode}'};
      }
    } catch (e) {
      print("Exception caught: $e");
      return {'success': false, 'message': 'Exception: $e'};
    }
  }
}

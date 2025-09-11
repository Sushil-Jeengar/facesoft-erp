import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/transport_model.dart';

class TransportApiService {
  static Future<List<Transport>?> fetchTransports() async {
    try {
      final response = await http.get(Uri.parse(API_Data.transports));
      print("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          print("Parsed transports data successfully");
          return (decoded['data'] as List)
              .map((json) => Transport.fromJson(json))
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

  static Future<bool> deleteTransport(int transportId) async {
    try {
      final response = await http.delete(
        Uri.parse('${API_Data.transports}/$transportId'),
        headers: {'Content-Type': 'application/json'},
      );
      print("Delete Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['success'] ?? false;
      } else {
        print("HTTP Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception caught: $e");
      return false;
    }
  }

  static Future<Transport?> createTransport(Transport transport) async {
    try {
      final response = await http.post(
        Uri.parse(API_Data.transports),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transport.toJson()),
      );
      print("Create Transport Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Transport.fromJson(decoded['data']); // Return the created transport
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception caught: $e");
      return null;
    }
    return null;
  }

  static Future<Transport?> updateTransport(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('${API_Data.transports}/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );
      print("Update Transport Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Transport.fromJson(decoded['data']); // Return the updated transport
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception caught: $e");
      return null;
    }
    return null;
  }
}

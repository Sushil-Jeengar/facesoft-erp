import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/agent_model.dart';
import 'package:http/http.dart' as http;

class AgentApiService {
  static Future<List<Agent>?> fetchAgents() async {
    try {
      final response = await http.get(Uri.parse(API_Data.agents));
      print("Status Code: ${response.statusCode}");
      // print("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null) {
          print("Parsed agents data successfully");
          return (decoded['data'] as List)
              .map((json) => Agent.fromJson(json))
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


  static Future<bool> deleteAgent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${API_Data.agents}/$id'),
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


  static Future<Agent?> createAgent(Agent agent) async {
    try {
      final response = await http.post(
        Uri.parse(API_Data.agents),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agent.toJson()),
      );
      print("Create Agent Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Agent.fromJson(decoded['data']); // Return the updated agent from backend
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


  static Future<Agent?> updateAgent(int id, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('${API_Data.agents}/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );
      print("Update Agent Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Agent.fromJson(decoded['data']);
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

import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:http/http.dart' as http;

class PlanApiService {

  /// Fetch all plans
  static Future<List<dynamic>> fetchPlans() async {
    try {
      final response = await http.get(Uri.parse(API_Data.plans));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["data"] ?? [];
      } else {
        throw Exception("Failed to fetch plans: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching plans: $e");
    }
  }
}

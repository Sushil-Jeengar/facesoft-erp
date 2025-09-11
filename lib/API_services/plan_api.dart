import 'dart:convert';
import 'package:http/http.dart' as http;

class PlanApiService {
  static const String baseUrl = "http://192.168.1.169:5000/v1/api/admin/plans";

  /// Fetch all plans
  static Future<List<dynamic>> fetchPlans() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

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

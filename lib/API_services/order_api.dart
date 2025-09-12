import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/order_model.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  static Future<List<Order>?> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse(API_Data.orders));
      print("Status Code: ${response.statusCode}");
      //print("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          print("Parsed orders data successfully");
          return (decoded['data'] as List)
              .map((json) => Order.fromJson(json))
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

  static Future<bool> updateOrder({
    required int orderId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${API_Data.orders}/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      print("Update Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        return decoded['success'] == true;
      }
      // Some backends return 201 or 204 on update
      if (response.statusCode == 201 || response.statusCode == 204) {
        return true;
      }
      print('Update failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print("Exception caught in updateOrder: $e");
      return false;
    }
  }

  static Future<bool> deleteOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('${API_Data.orders}/$orderId'),
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
}

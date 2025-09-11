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

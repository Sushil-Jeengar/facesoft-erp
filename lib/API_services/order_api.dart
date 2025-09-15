import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/order_model.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  static Future<List<Order>?> fetchOrders({int? userId}) async {
    try {
      Uri uri = userId != null 
          ? Uri.parse('${API_Data.orders}?user_id=$userId')
          : Uri.parse(API_Data.orders);
          
      final response = await http.get(uri);
      print("Status Code: ${response.statusCode}");
      //print("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          print("Parsed orders data successfully");
          List<Order> orders = (decoded['data'] as List)
              .map((json) => Order.fromJson(json))
              .toList();
              
          // Additional client-side filtering if needed
          if (userId != null) {
            orders = orders.where((order) => order.userId == userId).toList();
          }
          
          return orders;
        } else {
          print("API responded with success=false or missing data");
          return [];
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception caught in fetchOrders: $e");
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
      } else if (response.statusCode == 201 || response.statusCode == 204) {
        return true;
      } else {
        print("HTTP Error: ${response.statusCode}");
        return false;
      }
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
      print("Exception caught in deleteOrder: $e");
      return false;
    }
  }

  static Future<bool> bulkDeleteOrders(List<String> orderIds) async {
    try {
      final response = await http.post(
        Uri.parse(API_Data.bulkDeleteOrders),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ids': orderIds,
        }),
      );
      
      print("Bulk Delete Status Code: ${response.statusCode}");
      print("Bulk Delete Response: ${response.body}");
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print(response.body);
        return decoded['success'] == true;
      } else {
        print("HTTP Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception caught in bulkDeleteOrders: $e");
      return false;
    }
  }
}

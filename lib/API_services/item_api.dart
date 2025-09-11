import 'dart:convert';
import 'package:facesoft/API_services/api_data.dart';
import 'package:http/http.dart' as http;
import 'package:facesoft/model/item_model.dart';

class ItemApiService {
  static Future<List<Item>> fetchItems() async {
    try {
      final response = await http.get(Uri.parse(API_Data.items));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return (decoded['data'] as List)
              .map((json) => Item.fromJson(json))
              .toList();
        } else {
          throw Exception('Failed to load items: ${decoded['message']}');
        }
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }

  static Future<bool> deleteItem(String itemId) async {
    try {
      final response = await http.delete(Uri.parse('${API_Data.items}/$itemId'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['success'] ?? false;
      } else {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting item: $e');
    }
  }

  /// Create a new item
  static Future<Item?> createItem(Item item) async {
    try {
      final response = await http.post(
        Uri.parse(API_Data.items),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Item.fromJson(decoded['data']);
        }
        return null;
      } else {
        throw Exception('Failed to create item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating item: $e');
    }
  }

  /// Update item
  static Future<Item?> updateItem(String itemId, Item item) async {
    try {
      final response = await http.put(
        Uri.parse('${API_Data.items}/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Item.fromJson(decoded['data']);
        }
        return null;
      } else {
        throw Exception('Failed to update item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating item: $e');
    }
  }
}

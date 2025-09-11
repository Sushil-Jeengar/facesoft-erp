import 'dart:convert';
import 'dart:io';
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/supplier_model.dart';
import 'package:http/http.dart' as http;

class SupplierApiService {
  static Future<List<Supplier>?> fetchSuppliers() async {
    try {
      final response = await http.get(Uri.parse(API_Data.suppliers));
      print("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          print("Parsed suppliers data successfully");
          return (decoded['data'] as List)
              .map((json) => Supplier.fromJson(json))
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

  static Future<bool> deleteSupplier(int id) async {
    try {
      final response = await http.delete(Uri.parse('${API_Data.suppliers}/$id'));
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

  static Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> supplierData, {File? imageFile}) async {
    try {
      final uri = Uri.parse(API_Data.suppliers);
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll(supplierData.map((key, value) => MapEntry(key, value.toString())));
      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print("Create Status Code: ${response.statusCode}");
      print("Create Response Body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return {'success': true, 'data': decoded['data']};
        } else {
          return {'success': false, 'message': 'Failed to add supplier: ${response.statusCode}'};
        }
      } else {
        return {'success': false, 'message': 'Failed to add supplier: ${response.statusCode}'};
      }
    } catch (e) {
      print("Exception caught: $e");
      return {'success': false, 'message': 'Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSupplier(int id, Map<String, dynamic> updateData, {File? imageFile}) async {
    try {
      final uri = Uri.parse('${API_Data.suppliers}/$id');
      final request = http.MultipartRequest('PUT', uri);
      request.fields.addAll(updateData.map((key, value) => MapEntry(key, value.toString())));
      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print("Update Status Code: ${response.statusCode}");
      print("Update Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return {'success': true, 'message': decoded['message']};
        } else {
          return {'success': false, 'message': 'Failed to update supplier: ${response.statusCode}'};
        }
      } else {
        return {'success': false, 'message': 'Failed to update supplier: ${response.statusCode}'};
      }
    } catch (e) {
      print("Exception caught: $e");
      return {'success': false, 'message': 'Exception: $e'};
    }
  }
}

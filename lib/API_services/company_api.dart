import 'dart:convert';
import 'dart:io';
import 'package:facesoft/API_services/api_data.dart';
import 'package:facesoft/model/company_model.dart';
import 'package:http/http.dart' as http;

class CompanyApiService {
  static Future<List<Company>?> fetchCompanies() async {
    try {
      final response = await http.get(Uri.parse(API_Data.companies));
      print("Status Code: ${response.statusCode}");
      // print("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['data'] != null) {
                    return (decoded['data'] as List)
              .map((json) => Company.fromJson(json))
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


  static Future<bool> deleteCompany(String companyId) async {
    try {
      final response = await http.delete(
        Uri.parse('${API_Data.companies}/$companyId'),
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



  static Future<Company?> createCompany(Company company, int userId, {File? imageFile}) async {
    try {
      final uri = Uri.parse(API_Data.companies);
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'user_id': userId.toString(),
        'name': company.name ?? '',
        'website': company.website ?? '',
        'email': company.email ?? '',
        'phone': company.phone ?? '',
        'phone_code': company.phoneCode ?? '',
        'gst': company.gst ?? '',
        'opening_balance': company.openingBalance ?? '0',
        'address': company.address ?? '',
        'code': company.code ?? '',
        'city': company.city ?? '',
        'state': company.state ?? '',
        'country': company.country ?? '',
        'status': (company.status ?? true).toString(),
      });
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
          return Company.fromJson(decoded['data']);
        }
      }
      return null;
    } catch (e) {
      print("Exception caught: $e");
      return null;
    }
  }




  static Future<bool> updateCompany(Company company, {File? imageFile}) async {
    print("update api called");
    try {
      final uri = Uri.parse('${API_Data.companies}/${company.id}');
      final request = http.MultipartRequest('PUT', uri);
      request.fields.addAll({
        'user_id': (company.userId).toString(),
        'name': company.name ?? '',
        'website': company.website ?? '',
        'email': company.email ?? '',
        'phone': company.phone ?? '',
        'phone_code': company.phoneCode ?? '',
        'gst': company.gst ?? '',
        'opening_balance': company.openingBalance ?? '0',
        'address': company.address ?? '',
        'code': company.code ?? '',
        'city': company.city ?? '',
        'state': company.state ?? '',
        'country': company.country ?? '',
        'status': (company.status ?? true).toString(),
      });
      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Update Exception: $e');
      return false;
    }
  }
}


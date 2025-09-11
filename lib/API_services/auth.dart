import 'dart:convert';
import 'dart:developer';
import 'package:facesoft/model/auth_model.dart';
import 'package:http/http.dart' as http;
import 'api_data.dart';

class AuthService {
  // Send OTP for login (email or phone)
  static Future<Map<String, dynamic>> sendOtp(Map<String, String> args) async {
    try {
      print(jsonEncode(args));
      final response = await http.post(
        Uri.parse(API_Data.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(args),
      );

      if (response.statusCode == 200) {
        print(response.body);
        return {
          'success': true,
          'data': jsonDecode(response.body),

        };

      } else {
        print('error: $response');
        log('Failed to send OTP: ${response.statusCode}');
        return {
          'success': false,
        };
      }

    } catch (e) {
      print('error: $e');


      return {
        'success': false,
        'error': 'Network error: $e',
      };


    }
  }

  // Verify OTP
  static Future<AuthData?> verifyOtp(Map<String, String> args) async {
    try {
      final response = await http.post(
        Uri.parse(API_Data.verifyOtp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(args),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final decoded = jsonDecode(response.body);
        return AuthData.fromJson(decoded);
      } else {
        log('Failed to verify OTP: ${response.statusCode}');
        return null; // ya throw exception, apni choice
      }
    } catch (e) {
      log('Network error: $e');
      return null;  // ya throw exception
    }
  }
}
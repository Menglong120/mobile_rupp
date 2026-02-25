import 'dart:convert';
import 'dart:io';

import 'package:customer_order_app/core/utils/app_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> requestRestPS(String email) async {
    try {
      final url = Uri.parse('$baseUrl/customer/request-reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'OTP sent successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to send OTP',
          };
        }
      } else {
        return {'success': false, 'message': 'Invalid response format'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtpPS(
      String email, String otp) async {
    try {
      final url = Uri.parse('$baseUrl/customer/verify-reset-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'OTP verified successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Invalid OTP',
          };
        }
      } else {
        return {'success': false, 'message': 'Invalid response format'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/customer/reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Password reset successful',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to reset password',
          };
        }
      } else {
        return {'success': false, 'message': 'Invalid response format'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final url = Uri.parse('$baseUrl/customer/resend-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'OTP sent successfully',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to send OTP',
          };
        }
      } else {
        return {'success': false, 'message': 'Invalid response format'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> setupAccount({
    required String fullName,
    required String email,
    required String gender,
    required String phone,
    String? photo,
    File? photoFile,
  }) async {
    var url = Uri.parse('$baseUrl/customer/setup');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['full_name'] = fullName;
      request.fields['email'] = email;
      request.fields['gender'] = gender;
      request.fields['phone'] = phone;

      if (photoFile != null) {
        print('Photo path: ${photoFile.path}');
        print('Photo exists: ${await photoFile.exists()}');
        print('Photo length: ${await photoFile.length()}');
        request.files
            .add(await http.MultipartFile.fromPath('photo', photoFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid response format: Unable to parse server response'
        };
      }

      print('Full backend response: $responseData');

      final message =
          (responseData['message'] ?? responseData['msg'] ?? '').toLowerCase();
      final isSuccess = (responseData['status'] == true) ||
          message.contains('success') ||
          message.contains('successful');

      if (response.statusCode == 200 && isSuccess) {
        dynamic userId;
        if (responseData.containsKey('data')) {
          if (responseData['data'] is Map) {
            userId = responseData['data']['cid'];
          }
        }
        return {
          'success': true,
          'message': responseData['message'] ??
              responseData['meessage'] ??
              'Signup successful',
          'userId': userId,
          'data': responseData['data'],
        };
      } else {
        String errorMessage = responseData['message'] ??
            responseData['msg'] ??
            responseData['meessage'] ??
            (responseData['errors'] != null
                ? responseData['errors']
                    .entries
                    .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
                    .join('\n')
                : 'Signup failed');
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyUser(
    String email,
    String otp,
  ) async {
    var url = Uri.parse('$baseUrl/customer/verify');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        var responseData = jsonDecode(response.body);
        print('Raw backend response: $responseData');

        bool isSuccess = false;
        if ((responseData['message'] ?? '')
            .toLowerCase()
            .contains('verified')) {
          isSuccess = true;
        }

        if (response.statusCode == 200 && isSuccess) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          if (responseData['data'] != null) {
            await prefs.setString('userData', jsonEncode(responseData['data']));
          }

          return {
            'success': true,
            'message': responseData['message'] ?? 'Verification successful',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'OTP not correct',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Invalid response format',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'message',
      };
    }
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    var url = Uri.parse('$baseUrl/customer/auth');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        var responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Registration successful',
            'userId': responseData['data']?['cid'],
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Registration failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Invalid response format',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'message'};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    var url = Uri.parse('$baseUrl/customer/login');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        var responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData.containsKey('data')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userData', jsonEncode(responseData['data']));
          int? userId = responseData['data']['cid'];

          return {
            'success': true,
            'message': responseData['message'],
            'userId': userId,
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Invalid response format',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'message'};
    }
  }

  static Future<Map<String, dynamic>?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userData');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userData');
  }

  static Future<Map<String, dynamic>> updatePhoto({
    required String email,
    required File photoFile,
  }) async {
    var url = Uri.parse('$baseUrl/customer/photo');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['email'] = email;
      request.files
          .add(await http.MultipartFile.fromPath('photo', photoFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid response format: Unable to parse server response'
        };
      }

      print('Full backend response: $responseData');

      final message =
          (responseData['message'] ?? responseData['msg'] ?? '').toLowerCase();
      final isSuccess = (responseData['status'] == true) ||
          message.contains('success') ||
          message.contains('successful');

      if (response.statusCode == 200 && isSuccess) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Photo updated successfully',
          'data': responseData['data'],
        };
      } else {
        String errorMessage = responseData['message'] ??
            responseData['msg'] ??
            responseData['meessage'] ??
            (responseData['errors'] != null
                ? responseData['errors']
                    .entries
                    .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
                    .join('\n')
                : 'Photo update failed');
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error',
      };
    }
  }
}

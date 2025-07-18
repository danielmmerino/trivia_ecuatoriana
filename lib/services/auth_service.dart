import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service that handles authentication and stores the JWT token.
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  /// Base url of the backend loaded from the environment.
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Secret key loaded from the environment for API authentication.
  final String secretKey = dotenv.env['SECRET_KEY'] ?? '';

  String? token;

  /// Login using fixed credentials when the user continues as guest.
  Future<String> loginAsGuest() async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/login'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': secretKey,
      },
      body: jsonEncode({
        'email': 'daniel@gmail.com',
        'password': '123456',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final token = data['token'];
      if (token is String) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return token;
      }
    }
    throw Exception('Error al realizar login');
  }

  /// Login for social network sign in.
  Future<String> socialLogin() async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/social_login'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': secretKey,
      },
      body: jsonEncode({'email': 'juan@gmail.com'}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final token = data['token'];
      if (token is String) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return token;
      }
    }
    throw Exception('Error al realizar login');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

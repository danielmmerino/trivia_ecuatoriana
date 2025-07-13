import 'dart:convert';

import 'package:http/http.dart' as http;

/// Service that handles authentication and stores the JWT token.
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  /// Base url of the backend. Replace `{{URL}}` with the real host.
  final String baseUrl = '{{URL}}';

  String? token;

  /// Login using fixed credentials when the user continues as guest.
  Future<void> loginAsGuest() async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'daniel@gmail.com',
        'password': '123456',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      token = data['token']?.toString();
    } else {
      throw Exception('Failed to login as guest');
    }
  }

  /// Login for social network sign in.
  Future<void> socialLogin() async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/social_login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': 'juan@gmail.com'}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      token = data['token']?.toString();
    } else {
      throw Exception('Failed to login with social network');
    }
  }
}

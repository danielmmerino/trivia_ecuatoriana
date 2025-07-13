import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class QuestionService {
  Future<void> createQuestion(Map<String, dynamic> body) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    final url = Uri.parse('${baseUrl}api/crear_pregunta');
    final token = await AuthService().getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear pregunta');
    }
  }
}

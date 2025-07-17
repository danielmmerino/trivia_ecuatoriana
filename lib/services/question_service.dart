import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'auth_service.dart';
import '../models/question.dart';

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

  Future<List<Question>> fetchQuestions(int categoryId) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    final url = Uri.parse('${baseUrl}api/preguntas');
    final token = await AuthService().getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final body = {
      'id_categoria': categoryId,
      'limit': 1,
      'id_dificultad': Random().nextInt(3) + 1,
    };

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Question.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener preguntas');
  }
}

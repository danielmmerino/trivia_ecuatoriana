import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_service.dart';

class ResultService {
  Future<void> publishResult(int correct, int incorrect, String nickname) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/';
    final url = Uri.parse('${baseUrl}api/publicar_resultados');
    final token = await AuthService().getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final body = {
      'preguntasCorrectas': correct,
      'preguntasIncorrectas': incorrect,
      'nickname': nickname,
    };
    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al publicar resultados');
    }
  }
}

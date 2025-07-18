import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import 'auth_service.dart';

/// Service responsible for fetching trivia categories from the backend.
class CategoryService {
  Future<List<Category>> fetchCategories() async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
    final url = Uri.parse('${baseUrl}api/categories');
    final token = await AuthService().getToken();
    final headers = token != null
        ? <String, String>{
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          }
        : <String, String>{
            'Accept': 'application/json',
          };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    }
    throw Exception('Error al obtener información de las categorias');
  }
}

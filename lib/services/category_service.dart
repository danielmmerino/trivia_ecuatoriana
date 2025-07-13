import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';

/// Service responsible for fetching trivia categories from the backend.
class CategoryService {
  CategoryService._();

  static final CategoryService _instance = CategoryService._();
  factory CategoryService() => _instance;

  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final String secretKey = dotenv.env['SECRET_KEY'] ?? '';

  /// Fetch the list of categories from the backend API.
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${baseUrl}api/categorias'),
      headers: {'x-api-key': secretKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load categories');
  }
}

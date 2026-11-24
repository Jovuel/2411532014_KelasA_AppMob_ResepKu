import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:resepku/models/recipe.dart';

class RecipeService {
  RecipeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://dummyjson.com';
  static const _timeout = Duration(seconds: 10);

  Future<List<Recipe>> fetchRecipes({int limit = 50}) async {
    final uri = Uri.parse('$_baseUrl/recipes?limit=$limit');
    final response = await _client.get(uri).timeout(_timeout);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['recipes'] as List<dynamic>;
    return list.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Recipe> addRecipe({
    required String name,
    required String cuisine,
    required int cookTimeMinutes,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/recipes/add'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'cuisine': cuisine,
        'cookTimeMinutes': cookTimeMinutes,
      }),
    ).timeout(_timeout);
    _checkStatus(response);
    return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Latihan 1 — GET /recipes/search?q=... (spasi & karakter khusus di-encode oleh queryParameters)
  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse('$_baseUrl/recipes/search').replace(
      queryParameters: {'q': query},
    );
    final response = await _client.get(uri).timeout(_timeout);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['recipes'] as List<dynamic>;
    return list.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Latihan 2 — PUT /recipes/{id} (dummyjson hanya simulasi)
  Future<Recipe> updateRecipe(int id, {required String name}) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/recipes/$id'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'name': name}),
    ).timeout(_timeout);
    _checkStatus(response);
    return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Latihan 2 — DELETE /recipes/{id} (mengembalikan isDeleted: true)
  Future<bool> deleteRecipe(int id) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/recipes/$id'),
    ).timeout(_timeout);
    _checkStatus(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['isDeleted'] as bool? ?? false;
  }

  void _checkStatus(http.Response response) {
    if(response.statusCode < 200 || response.statusCode >= 300) {
      throw RecipeServiceException(
        'Server menjawab dengan status ${response.statusCode}',
      );
    }
  }
  void close() => _client.close();
}

class RecipeServiceException implements Exception {
  RecipeServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
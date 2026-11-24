import 'dart:convert';

import 'package:http/testing.dart';
import 'package:http/http.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Recipe.fromJson', () {
    test('membaca rating 5 (int) sebagai 5.0', () {
      final recipe = Recipe.fromJson({
        'id': 1,
        'name': 'Pasta',
        'cuisine': 'Italian',
        'difficulty': 'Easy',
        'prepTimeMinutes': 10,
        'cookTimeMinutes': 15,
        'servings': 2,
        'caloriesPerServing': 300,
        'rating': 5, // JSON tidak membedakan 5 dan 5.0
        'image': 'https://example.com/pasta.jpg',
        'ingredients': ['pasta', 'tomato'],
        'instructions': ['masak'],
      });

      expect(recipe.rating, 5.0);
      expect(recipe.id, 1);
      expect(recipe.name, 'Pasta');
    });

    test('memberi nilai bawaan untuk field yang tidak ada', () {
      final recipe = Recipe.fromJson({
        'id': 2,
        'name': 'Sederhana',
        'image': 'https://example.com/s.jpg',
      });

      expect(recipe.cuisine, '-');
      expect(recipe.difficulty, '-');
      expect(recipe.prepTimeMinutes, 0);
      expect(recipe.cookTimeMinutes, 0);
      expect(recipe.servings, 1);
      expect(recipe.caloriesPerServing, 0);
      expect(recipe.rating, 0.0);
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });
  });

  group('RecipeService.fetchRecipes', () {
    test('mengembalikan List<Recipe> dari respons palsu', () async {
      final body = jsonEncode({
        'recipes': [
          {
            'id': 1,
            'name': 'Pasta',
            'cuisine': 'Italian',
            'difficulty': 'Easy',
            'prepTimeMinutes': 10,
            'cookTimeMinutes': 15,
            'servings': 2,
            'caloriesPerServing': 300,
            'rating': 4.5,
            'image': 'https://example.com/pasta.jpg',
            'ingredients': ['pasta'],
            'instructions': ['rebus'],
          },
        ],
      });

      final client = MockClient((request) async {
        expect(request.url.toString(),
            'https://dummyjson.com/recipes?limit=50');
        return Response(body, 200);
      });

      final service = RecipeService(client: client);
      final recipes = await service.fetchRecipes();

      expect(recipes, hasLength(1));
      expect(recipes.first.name, 'Pasta');
      expect(recipes.first.rating, 4.5);
      service.close();
    });

    test('melempar RecipeServiceException jika status 404', () async {
      final client = MockClient((request) async {
        return Response('Not Found', 404);
      });

      final service = RecipeService(client: client);

      await expectLater(
        service.fetchRecipes(),
        throwsA(isA<RecipeServiceException>()),
      );
      service.close();
    });
  });
}
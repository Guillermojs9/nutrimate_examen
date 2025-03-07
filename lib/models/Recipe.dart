import 'package:NutriMate/models/entities.dart';

class Recipe {
  final String name;
  final String imageUrl;
  final List<String> instructions;
  final MealType type;
  final List<Map<String, dynamic>> ingredients;
  final String category;
  final int calories;

  Recipe({
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.type,
    required this.category,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'type': type.toString().split('.').last,
      'ingredients': ingredients,
      'category': category,
      'calories': calories,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      instructions: List<String>.from(map['instructions'] ?? []),
      type: MealType.values.firstWhere(
        (e) => e.toString() == 'MealType.${map['type']}',
        orElse: () => MealType.breakfast,
      ),
      ingredients: List<Map<String, dynamic>>.from(map['ingredients'] ?? []),
      category: map['category'] ?? '',
      calories: 0,
    );
  }
}

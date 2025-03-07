import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:NutriMate/providers/user_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../models/entities.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class InsertScreen extends StatefulWidget {
  const InsertScreen({super.key});

  @override
  InsertScreenState createState() => InsertScreenState();
}

class InsertScreenState extends State<InsertScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();

  final List<String> recipeCategories = [
    "Aumento masa muscular",
    "Alta en proteínas",
    "Bajo en grasas",
    "Equilibrado"
  ];
  String? selectedCategory;

  final Map<String, MealType> mealTypes = {
    "Desayuno": MealType.breakfast,
    "Almuerzo": MealType.lunch,
    "Cena": MealType.dinner
  };
  String? selectedMealTypeKey;
  MealType? selectedMealType;

  List<String> instructions = [];

  void addInstruction() {
    setState(() {
      instructions.add("");
    });
  }

  List<Map<String, dynamic>> parseIngredients(String ingredientsText) {
    List<Map<String, dynamic>> result = [];

    if (ingredientsText.trim().isEmpty) {
      return result;
    }

    List<String> ingredientsList = ingredientsText.split(',');

    for (String ingredient in ingredientsList) {
      String trimmedIngredient = ingredient.trim();
      if (trimmedIngredient.isNotEmpty) {
        result.add({"ingredientName": trimmedIngredient, "isSelected": false});
      }
    }

    return result;
  }

  void crearReceta() async {
    List<Map<String, dynamic>> ingredients =
        parseIngredients(ingredientsController.text);

    if (formKey.currentState!.validate() &&
        selectedCategory != null &&
        selectedMealType != null &&
        ingredients.isNotEmpty &&
        instructions.isNotEmpty) {
      final nuevaReceta = Recipe(
        name: nameController.text,
        imageUrl: imageUrlController.text,
        ingredients: ingredients,
        instructions: instructions,
        type: selectedMealType!,
        category: selectedCategory!,
        calories: caloriesController.text.isNotEmpty
            ? int.parse(caloriesController.text)
            : 0,
      );
      print("Nombre" + nuevaReceta.name);
      print("Imagen" + nuevaReceta.imageUrl);
      print("Ingredientes" + nuevaReceta.ingredients.length.toString());

      try {
        await FirebaseFirestore.instance.collection('menu_especial').add({
          'name': nuevaReceta.name,
          'imageUrl': nuevaReceta.imageUrl,
          'ingredients': nuevaReceta.ingredients,
          'instructions': nuevaReceta.instructions,
          'type': nuevaReceta.type.toString().split('.').last,
          'category': nuevaReceta.category,
          'calories': nuevaReceta.calories,
        });

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Receta creada correctamente",
          showConfirmBtn: true,
          confirmBtnText: "OK",
          confirmBtnColor: AppTheme.primary,
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      } catch (e) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error al crear la receta",
          confirmBtnText: "OK",
          confirmBtnColor: AppTheme.primary,
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Usuario usuario = Provider.of<UserProvider>(context).usuario!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppbar(title: 'Sugerir una receta', user: usuario),
        ],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Nombre de la receta"),
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa un nombre" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: "URL de la imagen"),
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa una URL" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: caloriesController,
                  decoration: InputDecoration(labelText: "Calorías"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa un número" : null,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: Text("Selecciona una categoría"),
                  items: recipeCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Selecciona una categoría" : null,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedMealTypeKey,
                  hint: Text("Selecciona el tipo de comida"),
                  items: mealTypes.keys.map((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMealTypeKey = value;
                      selectedMealType = mealTypes[value];
                    });
                  },
                  validator: (value) =>
                      value == null ? "Selecciona el tipo de comida" : null,
                ),
                SizedBox(height: 20),
                Text("Ingredientes",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: ingredientsController,
                  decoration: InputDecoration(
                    labelText: "Ingredientes",
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa al menos un ingrediente" : null,
                ),
                SizedBox(height: 20),
                Text("Instrucciones",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...instructions.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: "Paso ${index + 1}"),
                            onChanged: (value) {
                              instructions[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              instructions.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: addInstruction,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text("Añadir instrucción"),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: crearReceta,
                    child: Text("Crear Receta"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

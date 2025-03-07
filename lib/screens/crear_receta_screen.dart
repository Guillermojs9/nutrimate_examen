import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:NutriMate/providers/user_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../models/entities.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class CrearRecetaScreen extends StatefulWidget {
  const CrearRecetaScreen({super.key});

  @override
  CrearRecetaScreenState createState() => CrearRecetaScreenState();
}

class CrearRecetaScreenState extends State<CrearRecetaScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();

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

  List<Map<String, dynamic>> ingredients = [];
  List<String> instructions = [];

  void addIngredient() {
    setState(() {
      ingredients.add({"ingredientName": "", "isSelected": false});
    });
  }

  void addInstruction() {
    setState(() {
      instructions.add("");
    });
  }

  void crearReceta() async {
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

      try {
        await FirebaseFirestore.instance.collection('recetas').add({
          'name': nuevaReceta.name,
          'imageUrl': nuevaReceta.imageUrl,
          'ingredients': nuevaReceta.ingredients,
          'instructions': nuevaReceta.instructions,
          'type': nuevaReceta.type.toString().split('.').last,
          'category': nuevaReceta.category,
        });

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Receta creada correctamente",
          showConfirmBtn: true,
          confirmBtnText: "OK",
          confirmBtnColor: AppTheme.primary,
          barrierDismissible: false,
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
          CustomAppbar(title: 'Crear una receta', user: usuario),
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
                ...ingredients.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: "Ingrediente"),
                            onChanged: (value) {
                              ingredients[index]["ingredientName"] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              ingredients.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: addIngredient,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text("Añadir ingrediente"),
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

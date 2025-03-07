import 'package:NutriMate/models/entities.dart';
import 'package:NutriMate/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

Future<void> insertMenuDiario(MenuDiario menuDiario) async {
  final Map<String, dynamic> menu = menuDiario.toMap();
  await db.collection("menu_diario").add(menu);
}

Future<void> insertMenuSemanal(MenuSemanal menuSemanal) async {
  final Map<String, dynamic> menu = menuSemanal.toMap();
  await db.collection("menu_semanal").add(menu);
}

Future<void> updateMenuForUser(Usuario usuario, MenuSemanal newMenu) async {
  try {
    final QuerySnapshot userQuery = await db
        .collection("usuarios")
        .where("email", isEqualTo: usuario.email)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("Usuario no encontrado con el email: ${usuario.email}");
    }
    final String userId = userQuery.docs.first.id;
    final Map<String, dynamic> menuMap = newMenu.toMap();
    await db.collection("usuarios").doc(userId).update({'menu': menuMap});
    print("Menú del usuario actualizado con éxito");
  } catch (e) {
    print("Error al actualizar el menú del usuario: $e");
    throw e;
  }
}

//Obtener todos los menús semanales de la base de datos
Future<List<MenuSemanal>> gatMenusSemanales() async {
  final QuerySnapshot snapshot = await db.collection('menu_semanal').get();
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuSemanal.fromMap(data);
  }).toList();
}

//Obtener todos los menús diarios de la base de datos
Future<List<MenuDiario>> getMenusDiarios() async {
  final QuerySnapshot snapshot = await db.collection('menu_diario').get();
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return MenuDiario.fromMap(data);
  }).toList();
}

//Obtener todas las recetas equilibradas
Future<List<Recipe>> getRecetasPorCategoria(String category) async {
  final QuerySnapshot snapshot = await db
      .collection('recetas')
      .where('category', isEqualTo: category)
      .get();
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
        name: data['name'],
        imageUrl: data['imageUrl'],
        ingredients: List<Map<String, dynamic>>.from(data['ingredients']),
        instructions: List<String>.from(data['instructions']),
        type: MealType.values.firstWhere(
          (e) => e.toString().split('.').last == data['type'],
          orElse: () => MealType.breakfast,
        ),
        category: data['category'],
        calories: data['calories'].toDouble());
  }).toList();
}

Future<List<Recipe>> loadEquilibradas() async {
  final recetas = await getRecetasPorCategoria('Equilibrado');
  return recetas;
}

Future<List<Recipe>> loadProteinas() async {
  final recetas = await getRecetasPorCategoria('Alta en proteínas');
  return recetas;
}

Future<List<Recipe>> loadGrasas() async {
  final recetas = await getRecetasPorCategoria('Bajo en grasas');
  return recetas;
}

Future<List<Recipe>> loadAumentoMusculo() async {
  final recetas = await getRecetasPorCategoria('Aumento masa muscular');
  return recetas;
}

Future<void> deleteReceta(String nombreReceta) async {
  final QuerySnapshot recipeQuery = await db
      .collection('menu_especial')
      .where('name', isEqualTo: nombreReceta)
      .get();
  if (recipeQuery.docs.isEmpty) {
    throw Exception("Receta no encontrada con el nombre: $nombreReceta");
  }
  final String recipeId = recipeQuery.docs.first.id;
  print(recipeId);
  await db.collection('menu_especial').doc(recipeId).delete();
}

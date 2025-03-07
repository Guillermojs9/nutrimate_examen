import 'package:NutriMate/screens/screens.dart';
import 'package:NutriMate/services/firebase_menu_service.dart';
import 'package:NutriMate/services/firebase_service.dart';
import 'package:NutriMate/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NutriMate/providers/user_provider.dart';

import '../models/entities.dart';

class MenuEspecialScreen extends StatefulWidget {
  const MenuEspecialScreen({super.key});

  @override
  State<MenuEspecialScreen> createState() => _MenuEspecialScreenState();
}

class _MenuEspecialScreenState extends State<MenuEspecialScreen> {
  List<Recipe> recetas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecetas();
  }

  Future<void> loadRecetas() async {
    final recetasSugeridas = await getAllRecetasSugeridas();
    setState(() {
      recetas = recetasSugeridas;
      print("Numero de recetas" + recetas.length.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final Usuario usuario = Provider.of<UserProvider>(context).usuario!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppbar(title: 'Sugerir una receta', user: usuario),
        ],
        body: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: recetas.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final receta = recetas[index];
            final nombreReceta = receta.name;
            print("Ingrediente" + receta.ingredients.length.toString());
            final fotoReceta = receta.imageUrl[0];
            final nIngredientes = receta.ingredients.length;
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecetaDiariaScreen(receta: receta),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text('RE'),
                ),
                title: Text(nombreReceta),
                subtitle: Text('Numero de ingredientes: ${nIngredientes}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirmar = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Eliminar receta'),
                              content: Text(
                                  'Estás seguro de que deseas eliminar esta receta?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text('Eliminar'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                    if (confirmar) {
                      try {
                        await deleteReceta(receta.name);
        
                        setState(() {
                          recetas.removeAt(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Receta eliminada correctamente')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error al eliminar la receta: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(0, 200, 160, 1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertScreen(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

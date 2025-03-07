import 'package:NutriMate/screens/screens.dart';
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
            final nombreReceta = receta.name[0];
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

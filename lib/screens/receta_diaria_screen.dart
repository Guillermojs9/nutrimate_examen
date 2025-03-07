import 'package:flutter/material.dart';
import '../models/entities.dart';
import 'package:provider/provider.dart';
import 'package:NutriMate/providers/user_provider.dart';

import '../widgets/widgets.dart';
import 'screens.dart';

class RecetaDiariaScreen extends StatefulWidget {
  const RecetaDiariaScreen({super.key, required this.receta});
  final Recipe receta;

  @override
  _RecetaDiariaScreenState createState() => _RecetaDiariaScreenState();
}

class _RecetaDiariaScreenState extends State<RecetaDiariaScreen> {
  @override
  Widget build(BuildContext context) {
    final Usuario usuario = Provider.of<UserProvider>(context).usuario!;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppbar(title: widget.receta.name, user: usuario),
        ],
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InsertScreen()),
                    );
                  },
                  child: const Text('Cambiar menú'),
                ),
              ),
              _FoodImage(imageUrl: widget.receta.imageUrl),
              const Text(
                'Prepara estos ingredientes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    color: const Color(0xFF00B894).withAlpha(50),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: widget.receta.ingredients.map((ingrediente) {
                        return CheckboxListTile(
                          activeColor: const Color(0xFF00B894),
                          title: Text(ingrediente["ingredientName"]),
                          value: ingrediente["isSelected"],
                          onChanged: (bool? nuevoValor) {
                            setState(() {
                              ingrediente["seleccionado"] = nuevoValor!;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const Text(
                'Preparación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _RecipePreparation(instructions: widget.receta.instructions),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipePreparation extends StatelessWidget {
  final List<String> instructions;

  const _RecipePreparation({
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          color: const Color(0xFF00B894).withAlpha(50),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(instructions.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        instructions[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _FoodImage extends StatelessWidget {
  final String imageUrl;
  const _FoodImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, right: 15, left: 15, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: FadeInImage(
          placeholder: const AssetImage('assets/images/loading.gif'),
          image: NetworkImage(imageUrl),
          width: double.infinity,
          height: 260,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 700),
        ),
      ),
    );
  }
}

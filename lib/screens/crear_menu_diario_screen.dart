import 'package:NutriMate/models/entities.dart';
import 'package:NutriMate/services/firebase_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NutriMate/providers/user_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class CrearMenuDiarioScreen extends StatefulWidget {
  const CrearMenuDiarioScreen({super.key});

  @override
  State<CrearMenuDiarioScreen> createState() => _CrearMenuDiarioScreenState();
}

class _CrearMenuDiarioScreenState extends State<CrearMenuDiarioScreen> {
  final TextEditingController nombreController = TextEditingController();

  Recipe? desayunoSeleccionado;
  Recipe? almuerzoSeleccionado;
  Recipe? cenaSeleccionada;

  List<Recipe> _recetas = [];

  @override
  void initState() {
    super.initState();
    cargarRecetas();
  }

  Future<void> cargarRecetas() async {
    setState(() {});

    List<Recipe> equilibradas = await loadEquilibradas();
    List<Recipe> proteinas = await loadProteinas();
    List<Recipe> grasas = await loadGrasas();
    List<Recipe> musculo = await loadAumentoMusculo();

    setState(() {
      _recetas = [...equilibradas, ...proteinas, ...grasas, ...musculo];
    });
  }

  Future<void> guardarMenuDiario() async {
    if (nombreController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Por favor, introduzca el nombre del menú",
        showConfirmBtn: false,
      );
      return;
    }

    if (desayunoSeleccionado == null ||
        almuerzoSeleccionado == null ||
        cenaSeleccionada == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Por favor, seleccione tres recetas",
        showConfirmBtn: false,
      );
      return;
    }

    setState(() {});
    try {
      final menuDiario = MenuDiario(
        nombreMenuDiario: nombreController.text,
        recetas: [
          desayunoSeleccionado!,
          almuerzoSeleccionado!,
          cenaSeleccionada!
        ],
      );

      await insertMenuDiario(menuDiario);

      bool? result = await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Menú diario creado con éxito",
        showConfirmBtn: true,
        confirmBtnText: "Aceptar",
        barrierDismissible: false,
      );

      Navigator.pop(context);
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error al guardar",
        text: "Ha ocurrido un error al guardar el menú: $e",
        showConfirmBtn: true,
        confirmBtnText: "Entendido",
      );
    } finally {
      setState(() {});
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Usuario usuario = Provider.of<UserProvider>(context).usuario!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppbar(title: 'Crear menú diario', user: usuario),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del menú diario',
                ),
              ),
              const SizedBox(height: 20),
              _ComidaSection(
                title: 'Desayuno',
                mealType: MealType.breakfast,
                selectedRecipe: desayunoSeleccionado,
                onSelect: (recipe) =>
                    setState(() => desayunoSeleccionado = recipe),
                recetas: _recetas,
              ),
              const SizedBox(height: 20),
              _ComidaSection(
                title: 'Comida',
                mealType: MealType.lunch,
                selectedRecipe: almuerzoSeleccionado,
                onSelect: (recipe) =>
                    setState(() => almuerzoSeleccionado = recipe),
                recetas: _recetas,
              ),
              const SizedBox(height: 20),
              _ComidaSection(
                title: 'Cena',
                mealType: MealType.dinner,
                selectedRecipe: cenaSeleccionada,
                onSelect: (recipe) => setState(() => cenaSeleccionada = recipe),
                recetas: _recetas,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: guardarMenuDiario,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text('Guardar Menú Diario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComidaSection extends StatelessWidget {
  final String title;
  final MealType mealType;
  final Recipe? selectedRecipe;
  final Function(Recipe) onSelect;
  final List<Recipe> recetas;

  _ComidaSection({
    required this.title,
    required this.mealType,
    required this.selectedRecipe,
    required this.onSelect,
    required this.recetas,
  });

  @override
  Widget build(BuildContext context) {
    final recetasFiltradas = recetas.where((r) => r.type == mealType).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (selectedRecipe != null)
          Stack(
            children: [
              _RecipeCard(recipe: selectedRecipe!),
              Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(200, 30, 50, 1),
                  radius: 15,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, size: 15, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () =>
              _mostrarSelectorRecetas(context, recetasFiltradas, onSelect),
          icon: const Icon(Icons.add),
          label: Text(
              selectedRecipe == null ? 'Seleccionar $title' : 'Cambiar $title'),
        ),
      ],
    );
  }

  void _mostrarSelectorRecetas(
      BuildContext context, List<Recipe> recetas, Function(Recipe) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona una receta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: recetas.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay recetas disponibles para esta comida'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: recetas.length,
                          itemBuilder: (context, index) {
                            final recipe = recetas[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(recipe.imageUrl),
                              ),
                              title: Text(recipe.name),
                              subtitle: Text(recipe.category),
                              onTap: () {
                                onSelect(recipe);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(recipe.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Categoría: ${recipe.category}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${recipe.ingredients.length} ingredientes',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

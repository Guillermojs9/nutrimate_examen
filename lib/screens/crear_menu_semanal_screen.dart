import 'package:NutriMate/models/entities.dart';
import 'package:NutriMate/services/firebase_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NutriMate/providers/user_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class CrearMenuSemanalScreen extends StatefulWidget {
  const CrearMenuSemanalScreen({super.key});

  @override
  State<CrearMenuSemanalScreen> createState() => _CrearMenuSemanalScreenState();
}

class _CrearMenuSemanalScreenState extends State<CrearMenuSemanalScreen> {
  final TextEditingController nombreController = TextEditingController();
  final List<MenuDiario?> menusDiarios = List.filled(7, null);
  final List<String> diasSemanales = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  List<MenuDiario> menusDiariosDisponibles = [];

  @override
  void initState() {
    super.initState();
    _cargarMenusDiarios();
  }

  Future<void> _cargarMenusDiarios() async {
    setState(() {});
    final menusDiarios = await getMenusDiarios();

    setState(() {
      menusDiariosDisponibles = menusDiarios;
    });
  }

  Future<void> _guardarMenuSemanal() async {
    if (nombreController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Por favor, introduzca el nombre del menú",
        showConfirmBtn: true,
        confirmBtnText: "Entendido",
      );
      return;
    }

    final diasFaltantes = <String>[];
    for (int i = 0; i < 7; i++) {
      if (menusDiarios[i] == null) {
        diasFaltantes.add(diasSemanales[i]);
      }
    }

    if (diasFaltantes.isNotEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Faltan menús para: ${diasFaltantes.join(", ")}",
        showConfirmBtn: true,
        confirmBtnText: "Entendido",
      );
      return;
    }

    setState(() {});

    try {
      final menuSemanal = MenuSemanal(
        nombreMenuSemanal: nombreController.text,
        menusDiarios: menusDiarios.cast<MenuDiario>(),
      );

      await insertMenuSemanal(menuSemanal);

      bool? result = await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Menú semanal creado con éxito",
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
          CustomAppbar(title: 'Crear menú semanal', user: usuario),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del menú semanal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (menusDiariosDisponibles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No hay menús diarios disponibles. Crea algunos primero.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...List.generate(
                  7,
                  (index) => _DiaSection(
                    dia: diasSemanales[index],
                    dayIndex: index,
                    menuSeleccionado: menusDiarios[index],
                    onSelect: (menu) =>
                        setState(() => menusDiarios[index] = menu),
                    onRemove: () => setState(() => menusDiarios[index] = null),
                    menusDiariosDisponibles: menusDiariosDisponibles,
                  ),
                ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: menusDiariosDisponibles.isEmpty
                      ? null
                      : _guardarMenuSemanal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text('Guardar Menú Semanal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaSection extends StatelessWidget {
  final String dia;
  final int dayIndex;
  final MenuDiario? menuSeleccionado;
  final Function(MenuDiario?) onSelect;
  final VoidCallback onRemove;
  final List<MenuDiario> menusDiariosDisponibles;

  _DiaSection({
    required this.dia,
    required this.dayIndex,
    required this.menuSeleccionado,
    required this.onSelect,
    required this.onRemove,
    required this.menusDiariosDisponibles,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dia,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (menuSeleccionado != null)
            Stack(
              children: [
                _MenuDiarioCard(menu: menuSeleccionado!),
                Positioned(
                  top: 5,
                  right: 5,
                  child: CircleAvatar(
                    backgroundColor: Color.fromRGBO(200, 30, 50, 1),
                    radius: 15,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          size: 15, color: Colors.white),
                      onPressed: onRemove,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _mostrarSelectorMenus(context, dayIndex),
            icon: const Icon(Icons.add),
            label: Text(menuSeleccionado == null
                ? 'Seleccionar menú para $dia'
                : 'Cambiar menú para $dia'),
          ),
        ],
      ),
    );
  }

  void _mostrarSelectorMenus(BuildContext context, int dayIndex) {
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
                  'Selecciona un menú diario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: menusDiariosDisponibles.isEmpty
                      ? const Center(
                          child: Text('No hay menús diarios disponibles'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: menusDiariosDisponibles.length,
                          itemBuilder: (context, index) {
                            final menu = menusDiariosDisponibles[index];

                            String previewImage = '';
                            if (menu.recetas.isNotEmpty) {
                              previewImage = menu.recetas.first.imageUrl;
                            }

                            return ListTile(
                              leading: previewImage.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(previewImage),
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.restaurant_menu),
                                    ),
                              title: Text(menu.nombreMenuDiario),
                              subtitle: Text('${menu.recetas.length} recetas'),
                              onTap: () {
                                onSelect(menu);
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

class _MenuDiarioCard extends StatelessWidget {
  final MenuDiario menu;

  _MenuDiarioCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              menu.nombreMenuDiario,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('${menu.recetas.length} recetas incluidas'),
            const SizedBox(height: 16),
            if (menu.recetas.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: menu.recetas.map((receta) {
                  String tipoComida = '';

                  switch (receta.type) {
                    case MealType.breakfast:
                      tipoComida = 'Desayuno';
                      break;
                    case MealType.lunch:
                      tipoComida = 'Comida';
                      break;
                    case MealType.dinner:
                      tipoComida = 'Cena';
                      break;
                    default:
                      tipoComida = 'Desayuno';
                  }

                  return Chip(
                    avatar: CircleAvatar(
                      backgroundImage: NetworkImage(receta.imageUrl),
                    ),
                    label: Text('$tipoComida: ${receta.name}'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

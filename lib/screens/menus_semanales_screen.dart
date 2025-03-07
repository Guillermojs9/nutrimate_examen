import 'package:NutriMate/screens/screens.dart';
import 'package:NutriMate/services/firebase_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NutriMate/providers/user_provider.dart';

import '../models/entities.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class MenusSemanalesScreen extends StatefulWidget {
  final Usuario cliente;
  const MenusSemanalesScreen({super.key, required this.cliente});

  @override
  State<MenusSemanalesScreen> createState() => _MenusSemanalesScreenState();
}

class _MenusSemanalesScreenState extends State<MenusSemanalesScreen> {
  List<MenuSemanal> _menusSemanales = [];

  @override
  void initState() {
    super.initState();
    _loadMenusSemanales();
  }

  Future<void> _loadMenusSemanales() async {
    final menusSemanales = await gatMenusSemanales();
    setState(() {
      _menusSemanales = menusSemanales;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Usuario usuario = Provider.of<UserProvider>(context).usuario!;
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        CustomAppbar(title: 'Ménus semanales disponibles', user: usuario),
      ],
      body: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _menusSemanales.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final main = _menusSemanales[index];
          return InkWell(
            onTap: () {
              updateMenuForUser(widget.cliente, main);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientesScreen(),
                ),
              );
            },
            child: ListTile(
              title: Text(main.nombreMenuSemanal),
            ),
          );
        },
      ),
    ));
  }
}

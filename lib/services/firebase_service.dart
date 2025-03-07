import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entities.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Registra los datos de un usuario en la base de datos
Future<void> insertUser(String nombre, String apellido, String email) async {
  await db
      .collection("usuarios")
      .add({"nombre": nombre, "apellido": apellido, "email": email});
}

// Obtener los datos de un usuario
Future<Map<String, dynamic>?> getUserData(String uid) async {
  final doc =
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
  return doc.data();
}

Future<void> updateUserWeigth(String uid, double newWeight) async {
  await db.collection('usuarios').doc(uid).update({'peso': newWeight});
}

Future<void> updateUser(String uid, String email, String nombre,
    String apellido, double newHeight) async {
  await db.collection('usuarios').doc(uid).update({
    'email': email,
    'nombre': nombre,
    'apellido': apellido,
    'peso': newHeight
  });
}

//Obtener todos los usuarios de la base de datos
Future<List<Usuario>> getAllUsers() async {
  final QuerySnapshot snapshot = await db.collection('usuarios').get();
  return snapshot.docs
      .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Usuario.fromMap(data);
      })
      .where((usuario) => usuario.email != "admin@nutrimate.com")
      .toList();
}

Future<List<Recipe>> getAllRecetasSugeridas() async {
  final QuerySnapshot snapshot = await db.collection('menu_especial').get();
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Recipe.fromMap(data);
  }).toList();
}

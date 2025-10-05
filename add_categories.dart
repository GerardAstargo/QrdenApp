import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import './firebase_options.dart'; // Make sure this path is correct

// This is a standalone script to add categories to Firestore.
// To run it, use the command: dart run add_categories.dart

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final categories = [
    'Quesos',
    'Cereales',
    'Lácteos',
    'Carnes',
    'Frutas y Verduras',
    'Panadería',
    'Bebidas
',    'Limpieza',
    'Abarrotes',
  ];

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('categories');

  print('Iniciando la adición de categorías...');

  for (final categoryName in categories) {
    try {
      final query = await collection.where('nombrecategoria', isEqualTo: categoryName).limit(1).get();
      if (query.docs.isEmpty) {
        await collection.add({'nombrecategoria': categoryName});
        print('Categoría añadida: $categoryName');
      } else {
        print('La categoría "$categoryName" ya existe.');
      }
    } catch (e) {
      print('Error al añadir la categoría "$categoryName": $e');
    }
  }

  print('Proceso de adición de categorías completado.');
}

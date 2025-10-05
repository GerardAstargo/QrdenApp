
import 'package:cloud_firestore/cloud_firestore.dart';

// Función para añadir categorías a Firestore
Future<void> addCategories() async {
  final categories = [
    'Quesos',
    'Cereales',
    'Lácteos',
    'Carnes',
    'Frutas y Verduras',
    'Panadería',
    'Bebidas',
    'Limpieza',
    
  ];

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('categories');

  // Usar un bucle for...of para asegurar que se completen las operaciones
  for (final categoryName in categories) {
    try {
      // Verificar si la categoría ya existe para no duplicarla
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

  print('Proceso de añadir categorías completado.');
}

// Para ejecutar este script, puedes llamarlo desde algún lugar de tu app,
// por ejemplo, en un botón de uso único o al inicio si es necesario.
// Ejemplo:
//
// ElevatedButton(
//   onPressed: addCategories,
//   child: const Text('Añadir Categorías'),
// )

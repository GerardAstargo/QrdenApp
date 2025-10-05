
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// IMPORTANTE: Este script está diseñado para ejecutarse una vez desde la línea de comandos.
// Para ejecutar: dart run lib/migration_script.dart

void main() async {
  print('Iniciando script de migración de datos...');

  // Asegúrate de que los widgets de Flutter no se inicialicen, ya que es una app de consola.
  // WidgetsFlutterBinding.ensureInitialized(); // No necesario para una app de consola pura.

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final db = FirebaseFirestore.instance;

  try {
    // 1. Obtener todas las categorías y crear un mapa de nombre a referencia
    print('Obteniendo categorías...');
    final categoriesSnapshot = await db.collection('categoria').get();
    final categoryMap = <String, DocumentReference>{};
    for (final doc in categoriesSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('nombrecategoria')) {
        final categoryName = data['nombrecategoria'] as String;
        // Guardar en minúsculas para una coincidencia sin distinción de mayúsculas/minúsculas
        categoryMap[categoryName.toLowerCase()] = doc.reference;
        print('  - Categoría encontrada: $categoryName');
      }
    }
    print('Se encontraron ${categoryMap.length} categorías.');

    if (categoryMap.isEmpty) {
        print('Advertencia: No se encontraron categorías. No se pueden migrar los productos.');
        return;
    }

    // 2. Obtener todos los productos
    print('\nObteniendo productos...');
    final productsSnapshot = await db.collection('producto').get();
    print('Se encontraron ${productsSnapshot.docs.length} productos para verificar.');

    int migratedCount = 0;
    final batch = db.batch();

    // 3. Iterar y migrar cada producto si es necesario
    for (final productDoc in productsSnapshot.docs) {
      final productData = productDoc.data();
      final categoryField = productData['categoria'];

      // Comprobar si el campo 'categoria' es un String
      if (categoryField is String) {
        print('  - Migrando producto: ${productDoc.id} (Nombre: ${productData['nombreproducto']})');
        print('    Categoría antigua (String): "$categoryField"');

        final categoryRef = categoryMap[categoryField.toLowerCase()];

        if (categoryRef != null) {
          // Si se encuentra una categoría coincidente, añadir la actualización al lote
          batch.update(productDoc.reference, {'categoria': categoryRef});
          print('    Nueva categoría (Referencia): ${categoryRef.path}');
          migratedCount++;
        } else {
          // Si no se encuentra coincidencia, establecer a null para evitar futuros errores
          batch.update(productDoc.reference, {'categoria': null});
          print('    Advertencia: No se encontró categoría coincidente para "$categoryField". Se establecerá a null.');
        }
      } else {
        // Si no es un string, asumimos que ya está correcto (o es null) y lo omitimos
        // print('  - Omitiendo producto (ya migrado o sin categoría): ${productDoc.id}');
      }
    }

    // Si se migraron productos, ejecutar el lote
    if (migratedCount > 0) {
      print('\nEjecutando actualización por lotes para $migratedCount productos...');
      await batch.commit();
      print('¡Lote ejecutado con éxito!');
    } else {
      print('\nNo se necesitaron migraciones.');
    }


    print('\n¡Migración completada!');
    print('$migratedCount productos fueron migrados exitosamente.');

  } catch (e, s) {
    print('\nOcurrió un error durante la migración: $e');
    print('Stack trace: $s');
  }
}

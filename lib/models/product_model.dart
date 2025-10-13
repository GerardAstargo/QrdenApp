import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String? code; // Added 'code' field
  final DocumentReference? category;
  final int quantity;
  final double price;
  final Timestamp? fechaIngreso;
  final String? enteredBy;
  final String? numeroEstante;

  Product({
    required this.id,
    required this.name,
    this.code,
    this.category,
    required this.quantity,
    required this.price,
    this.fechaIngreso,
    this.enteredBy,
    this.numeroEstante,
  });

  // Factory constructor to create a Product from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // --- Robust Timestamp parsing ---
    Timestamp? ingresoTimestamp;
    final ingresoData = data['fechaingreso'];
    if (ingresoData is Timestamp) {
      ingresoTimestamp = ingresoData;
    } else if (ingresoData is String) {
      // Attempt to parse the string date. This is a basic example.
      // NOTE: The string format "24 de septiembre de 2025, 12:05:22p.m. UTC-3"
      // is complex and might require a more specific locale-based parsing.
      // For now, we handle it gracefully.
      try {
        // This is a simplification; a more robust parser might be needed.
        ingresoTimestamp = Timestamp.fromDate(DateFormat("d 'de' MMMM 'de' yyyy, h:mm:ss a 'UTC'Z", 'es').parse(ingresoData));
      } catch (e) {
        // If parsing fails, leave it as null
        ingresoTimestamp = null;
      }
    }

    return Product(
      id: doc.id,
      name: data['nombreproducto'] ?? 'Sin Nombre',
      code: data['codigo']?.toString(), // Read 'codigo' and convert to String
      category: data['categoria'] as DocumentReference?,
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      fechaIngreso: ingresoTimestamp,
      enteredBy: data['ingresadoPor'] as String?,
      numeroEstante: data['numeroEstante'] as String?,
    );
  }

  // Method to convert a Product object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombreproducto': name,
      'codigo': code,
      'categoria': category,
      'stock': quantity,
      'precio': price,
      'fechaingreso': fechaIngreso ?? FieldValue.serverTimestamp(),
      'ingresadoPor': enteredBy,
      'numeroEstante': numeroEstante,
    };
  }
}

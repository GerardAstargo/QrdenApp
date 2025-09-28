import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;          // Standardized from qrCode
  final String name;
  final String description;   // Maps to 'categoria' in Firestore
  final int quantity;
  final double price;         // Standardized from precio
  final Timestamp? fechaIngreso;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    this.fechaIngreso,
  });

  // Factory to create a Product from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id, // Use the document ID as the product ID
      name: data['nombreproducto'] ?? 'Nombre no disponible',
      description: data['categoria'] ?? 'Sin categoría',
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      fechaIngreso: data['fechaingreso'] as Timestamp?,
    );
  }

  // Method to convert a Product object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombreproducto': name,
      'categoria': description,
      'stock': quantity,
      'precio': price,
      'fechaingreso': fechaIngreso ?? FieldValue.serverTimestamp(), // Set current time if null
    };
  }
}

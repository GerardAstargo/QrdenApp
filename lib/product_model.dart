import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final DocumentReference? category; // Changed from description: String
  final int quantity;
  final double price;
  final Timestamp? fechaIngreso;

  Product({
    required this.id,
    required this.name,
    this.category, // Changed from description
    required this.quantity,
    required this.price,
    this.fechaIngreso,
  });

  // Factory to create a Product from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['nombreproducto'] ?? 'Nombre no disponible',
      // The 'categoria' field is now a DocumentReference
      category: data['categoria'] as DocumentReference?,
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      fechaIngreso: data['fechaingreso'] as Timestamp?,
    );
  }

  // Method to convert a Product object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombreproducto': name,
      'categoria': category, // Stores the reference
      'stock': quantity,
      'precio': price,
      'fechaingreso': fechaIngreso ?? FieldValue.serverTimestamp(),
    };
  }
}

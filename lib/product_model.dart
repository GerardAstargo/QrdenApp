import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String qrCode;
  final String name;
  final String description;
  final int quantity;
  final double precio; // Added precio
  final Timestamp? fechaingreso; // Added fechaingreso, can be null

  Product({
    required this.qrCode,
    required this.name,
    required this.description,
    required this.quantity,
    required this.precio,
    this.fechaingreso,
  });

  // Updated factory constructor to map all Firestore fields
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      qrCode: doc.id,
      name: data['nombreproducto'] ?? 'Nombre no disponible',
      description: data['categoria'] ?? 'Sin categoría',
      quantity: (data['stock'] ?? 0).toInt(),
      // Reads 'precio' from Firestore
      precio: (data['precio'] ?? 0.0).toDouble(),
      // Reads 'fechaingreso' from Firestore
      fechaingreso: data['fechaingreso'] as Timestamp?,
    );
  }
}

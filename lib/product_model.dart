import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final DocumentReference? category;
  final int quantity;
  final double price;
  final Timestamp? fechaIngreso;
  final String? enteredBy; // Employee who entered the product

  Product({
    required this.id,
    required this.name,
    this.category,
    required this.quantity,
    required this.price,
    this.fechaIngreso,
    this.enteredBy,
  });

  // Factory constructor to create a Product from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle potential type mismatch for 'categoria'
    DocumentReference? categoryRef;
    final categoryData = data['categoria'];
    if (categoryData is DocumentReference) {
      categoryRef = categoryData;
    }
    // If categoryData is a String (or anything else), categoryRef remains null, preventing the cast error.

    Timestamp? ingresoTimestamp;
    final ingresoData = data['fechaingreso'];
    if (ingresoData is Timestamp) {
      ingresoTimestamp = ingresoData;
    }

    return Product(
      id: doc.id,
      name: data['nombreproducto'] ?? 'Nombre no disponible',
      category: categoryRef, // Safely assigned
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      fechaIngreso: ingresoTimestamp, // Safely assigned
      enteredBy: data['ingresadoPor'] as String?,
    );
  }

  // Method to convert a Product object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombreproducto': name,
      'categoria': category,
      'stock': quantity,
      'precio': price,
      'fechaingreso': fechaIngreso ?? FieldValue.serverTimestamp(),
      'ingresadoPor': enteredBy,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final DocumentReference? category;
  final int quantity;
  final double price;
  final Timestamp? fechaIngreso;
  final String? enteredBy; // Employee who entered the product
  final String? numeroEstante; // Shelf number where the product is located

  Product({
    required this.id,
    required this.name,
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

    DocumentReference? categoryRef;
    final categoryData = data['categoria'];
    if (categoryData is DocumentReference) {
      categoryRef = categoryData;
    }

    Timestamp? ingresoTimestamp;
    final ingresoData = data['fechaingreso'];
    if (ingresoData is Timestamp) {
      ingresoTimestamp = ingresoData;
    }

    return Product(
      id: doc.id,
      name: data['nombreproducto'] ?? 'Nombre no disponible',
      category: categoryRef,
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
      'categoria': category,
      'stock': quantity,
      'precio': price,
      'fechaingreso': fechaIngreso ?? FieldValue.serverTimestamp(),
      'ingresadoPor': enteredBy,
      'numeroEstante': numeroEstante,
    };
  }
}

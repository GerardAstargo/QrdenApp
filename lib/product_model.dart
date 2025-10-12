import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // This is the QR Code, and the document ID
  final String name;
  final DocumentReference? category;
  final int quantity;
  final double price;
  final String? numeroEstante;
  final Timestamp? fechaIngreso;
  final String? enteredBy;

  Product({
    required this.id,
    required this.name,
    this.category,
    required this.quantity,
    required this.price,
    this.numeroEstante,
    this.fechaIngreso,
    this.enteredBy,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['nombre'] ?? '',
      category: data['categoria'],
      quantity: data['stock'] ?? 0,
      price: (data['precio'] ?? 0.0).toDouble(),
      numeroEstante: data['numero_estante'],
      fechaIngreso: data['fecha_ingreso'],
      enteredBy: data['ingresado_por'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': name,
      'categoria': category,
      'stock': quantity,
      'precio': price,
      'numero_estante': numeroEstante,
      // The id is the document name, so it's not stored inside the document
      if (fechaIngreso != null) 'fecha_ingreso': fechaIngreso,
      if (enteredBy != null) 'ingresado_por': enteredBy,
    };
  }
}

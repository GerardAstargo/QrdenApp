import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String qrCode;
  final String name;
  final String description;
  final int quantity;

  Product({
    required this.qrCode,
    required this.name,
    required this.description,
    required this.quantity,
  });

  // Updated factory constructor to map Firestore fields correctly
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      qrCode: doc.id, // The document ID is the QR code
      // Reads 'nombreproducto' from Firestore, assigns to 'name' in the app
      name: data['nombreproducto'] ?? 'Nombre no disponible',
      // Reads 'categoria' from Firestore, assigns to 'description' in the app
      description: data['categoria'] ?? 'Sin categoría',
      // Reads 'stock' from Firestore, assigns to 'quantity' in the app
      quantity: data['stock'] ?? 0,
    );
  }
}

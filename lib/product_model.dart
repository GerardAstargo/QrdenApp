import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Product {
  // The true unique ID for the database document.
  final String internalId;
  // The QR code, now just a piece of data.
  final String qrCode;
  final String name;
  final DocumentReference? category;
  final int quantity;
  final double price;
  final Timestamp? fechaIngreso;
  final String? enteredBy;
  final String? numeroEstante;

  Product({
    String? internalId, // Make optional
    required this.qrCode, // The scanned QR code
    required this.name,
    this.category,
    required this.quantity,
    required this.price,
    this.fechaIngreso,
    this.enteredBy,
    this.numeroEstante,
  }) : internalId = internalId ?? const Uuid().v4(); // Generate new ID if not provided

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      internalId: doc.id, // The document ID from Firestore is our internalId
      qrCode: data['qrCode'] ?? 'N/A', // Load the QR code
      name: data['nombreproducto'] ?? 'Nombre no disponible',
      category: data['categoria'] is DocumentReference ? data['categoria'] : null,
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      fechaIngreso: data['fechaingreso'] as Timestamp?,
      enteredBy: data['ingresadoPor'] as String?,
      numeroEstante: data['numeroEstante'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'qrCode': qrCode, // Save the QR code
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

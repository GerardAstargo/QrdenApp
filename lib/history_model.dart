import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id; // The unique ID of the history document itself
  final String productId; // The ID of the product (e.g., the QR code)
  final String name;
  final DocumentReference? category;
  final int quantity;
  final double price;
  final String? enteredBy;
  final String? numeroEstante;

  final Timestamp fechaIngreso;
  final Timestamp? fechaSalida; // Nullable: will be set on deletion

  HistoryEntry({
    required this.id,
    required this.productId,
    required this.name,
    this.category,
    required this.quantity,
    required this.price,
    this.enteredBy,
    this.numeroEstante,
    required this.fechaIngreso,
    this.fechaSalida, 
  });

  factory HistoryEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DocumentReference? categoryRef;
    if (data['categoria'] is DocumentReference) {
      categoryRef = data['categoria'];
    }

    return HistoryEntry(
      id: doc.id, // The history document's own unique ID
      productId: data['productId'] ?? '', // The ID of the scanned product
      name: data['nombreproducto'] ?? 'N/A',
      category: categoryRef,
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      enteredBy: data['ingresadoPor'] as String?,
      numeroEstante: data['numeroEstante'] as String?,
      fechaIngreso: data['fecha_ingreso'] as Timestamp? ?? Timestamp.now(),
      fechaSalida: data['fecha_salida'] as Timestamp?, // Can be null
    );
  }
}

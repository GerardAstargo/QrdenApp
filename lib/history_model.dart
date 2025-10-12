import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id; // Document ID of the history entry itself
  final String productId; // ID of the product (the QR code)
  final String name;
  final int quantity;
  final double price;
  final Timestamp fechaIngreso;
  final Timestamp? fechaSalida;

  HistoryEntry({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.fechaIngreso,
    this.fechaSalida,
  });

  factory HistoryEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HistoryEntry(
      id: doc.id,
      // 'id' field inside the document stores the original product QR code
      productId: data['id'] ?? '',
      name: data['nombre'] ?? '',
      quantity: data['stock'] ?? 0,
      price: (data['precio'] ?? 0.0).toDouble(),
      fechaIngreso: data['fecha_ingreso'] ?? Timestamp.now(),
      fechaSalida: data['fecha_salida'],
    );
  }
}

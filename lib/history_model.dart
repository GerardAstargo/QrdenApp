import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String historyId; // The unique ID of the history document itself
  final String internalId; // The unique ID of the product being referenced
  final String qrCode; // The QR code associated with the product

  final String name;
  final DocumentReference? category;
  final int quantity;
  final double price;
  final String? enteredBy;
  final String? numeroEstante;

  final Timestamp fechaIngreso;
  final Timestamp? fechaSalida; // Nullable: will be set on deletion

  HistoryEntry({
    required this.historyId,
    required this.internalId,
    required this.qrCode,
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

    return HistoryEntry(
      historyId: doc.id,
      internalId: data['internalId'] ?? '',
      qrCode: data['qrCode'] ?? 'N/A',
      name: data['nombreproducto'] ?? 'N/A',
      category: data['categoria'] is DocumentReference ? data['categoria'] : null,
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      enteredBy: data['ingresadoPor'] as String?,
      numeroEstante: data['numeroEstante'] as String?,
      fechaIngreso: data['fecha_ingreso'] as Timestamp? ?? Timestamp.now(),
      fechaSalida: data['fecha_salida'] as Timestamp?,
    );
  }
}

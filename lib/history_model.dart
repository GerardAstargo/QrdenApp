import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id;
  final String name;
  final DocumentReference? category;
  final int quantity;
  final double price;
  final Timestamp? fechaIngresoOriginal;
  final String? enteredBy;
  final String? numeroEstante;

  // Audit fields
  final String accion; // 'entrada' or 'salida'
  final Timestamp fechaMovimiento; // The timestamp of the audit event

  HistoryEntry({
    required this.id,
    required this.name,
    this.category,
    required this.quantity,
    required this.price,
    this.fechaIngresoOriginal,
    this.enteredBy,
    this.numeroEstante,
    required this.accion,
    required this.fechaMovimiento,
  });

  // Factory constructor to create a HistoryEntry from a Firestore document
  factory HistoryEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Safely get the category reference
    DocumentReference? categoryRef;
    if (data['categoria'] is DocumentReference) {
      categoryRef = data['categoria'];
    }

    return HistoryEntry(
      id: doc.id, // This is the ID of the history document itself
      name: data['nombreproducto'] ?? 'N/A',
      category: categoryRef,
      quantity: (data['stock'] ?? 0).toInt(),
      price: (data['precio'] ?? 0.0).toDouble(),
      fechaIngresoOriginal: data['fecha_ingreso_original'] as Timestamp?,
      enteredBy: data['ingresadoPor'] as String?,
      numeroEstante: data['numeroEstante'] as String?,
      
      // Audit fields from the 'registro' collection
      accion: data['accion'] ?? 'desconocido',
      fechaMovimiento: data['fecha_movimiento'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

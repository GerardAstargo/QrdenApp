import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id;
  final String name;
  final String categoryId;
  final int quantity;
  final double price;
  final String addedBy;
  final Timestamp fechaIngreso;
  final Timestamp? fechaSalida;

  HistoryEntry({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.quantity,
    required this.price,
    required this.addedBy,
    required this.fechaIngreso,
    this.fechaSalida,
  });

  factory HistoryEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle category, which could be a DocumentReference
    String categoryIdStr = '';
    if (data['categoria'] is DocumentReference) {
      categoryIdStr = (data['categoria'] as DocumentReference).id;
    } else if (data['categoria'] is String) {
      categoryIdStr = data['categoria'];
    }

    return HistoryEntry(
      id: doc.id,
      // Use the correct field names from what is stored in Firestore
      name: data['nombreproducto'] ?? 'Sin Nombre',
      categoryId: categoryIdStr,
      quantity: data['stock'] ?? 0,
      price: (data['precio'] ?? 0.0).toDouble(),
      addedBy: data['ingresadoPor'] ?? 'Desconocido',
      fechaIngreso: data['fecha_ingreso'] ?? Timestamp.now(),
      fechaSalida: data['fecha_salida'], // Can be null
    );
  }
}

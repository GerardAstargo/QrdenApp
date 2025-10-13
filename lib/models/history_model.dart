import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id;
  final String name;
  final String categoryId;
  final int quantity;
  final double price;
  final String addedBy;
  final Timestamp fechaIngreso;
  final Timestamp? fechaSalida; // Nullable, as it might not be set

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
    return HistoryEntry(
      id: doc.id,
      name: data['nombre'] ?? '',
      categoryId: data['categoria'] ?? '',
      quantity: data['stock'] ?? 0,
      price: (data['precio'] ?? 0.0).toDouble(),
      addedBy: data['ingresado_por'] ?? '',
      fechaIngreso: data['fecha_ingreso'] ?? Timestamp.now(),
      fechaSalida: data['fecha_salida'], // Can be null
    );
  }
}

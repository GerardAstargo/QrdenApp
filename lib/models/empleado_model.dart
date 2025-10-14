import 'package:cloud_firestore/cloud_firestore.dart';

class Empleado {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String rut;
  final String telefono;
  final DocumentReference? cargo; // Make cargo nullable

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rut,
    required this.telefono,
    this.cargo, // Make cargo optional in constructor
  });

  factory Empleado.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Empleado(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      email: data['email'] ?? '',
      rut: data['rut'] ?? '',
      telefono: data['telefono'] ?? '',
      // Safely parse the cargo field
      cargo: data.containsKey('cargo') && data['cargo'] is DocumentReference
          ? data['cargo'] as DocumentReference
          : null,
    );
  }
}

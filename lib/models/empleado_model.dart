import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class Empleado {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String cargo;
  final String rut;
  final String telefono;

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.cargo,
    required this.rut,
    required this.telefono,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Empleado.fromMap(Map<String, dynamic> data, String documentId) {
    String parsedCargo = 'Cargo no especificado';
    try {
      dynamic cargoData = data['cargo'];
      if (cargoData is DocumentReference) {
        // It's a DocumentReference, get the last part of the path
        parsedCargo = cargoData.path.split('/').last;
      } else if (cargoData is String) {
        // It's a String, handle both plain text and reference-like strings
        if (cargoData.contains('/')) {
          parsedCargo = cargoData.split('/').last;
        } else {
          parsedCargo = cargoData;
        }
      } 
    } catch (e) {
        developer.log('Could not parse cargo: $e', name: 'EmpleadoModel');
    }

    return Empleado(
      id: documentId,
      nombre: data['nombre'] ?? 'Nombre no encontrado',
      apellido: data['apellido'] ?? '',
      email: data['email'] ?? 'Email no encontrado',
      cargo: parsedCargo, // Use the safely parsed cargo
      rut: data['rut'] ?? 'RUT no encontrado',
      telefono: data['telefono']?.toString() ?? 'Teléfono no encontrado', // Safely convert telefono to String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'cargo': cargo, 
      'rut': rut,
      'telefono': telefono,
    };
  }
}

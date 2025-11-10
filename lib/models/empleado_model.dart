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
  final String? securityPin;

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.cargo,
    required this.rut,
    required this.telefono,
    this.securityPin,
  });

  String get nombreCompleto => '$nombre $apellido';

  bool get hasPin => securityPin != null && securityPin!.isNotEmpty;

  factory Empleado.fromMap(Map<String, dynamic> data, String documentId) {
    String parsedCargo = 'Cargo no especificado';
    try {
      dynamic cargoData = data['cargo'];
      if (cargoData is DocumentReference) {
        parsedCargo = cargoData.path.split('/').last;
      } else if (cargoData is String) {
        if (cargoData.contains('/')) {
          parsedCargo = cargoData.split('/').last;
        } else {
          parsedCargo = cargoData;
        }
      }
    } catch (e) {
      developer.log('Could not parse cargo: $e', name: 'EmpleadoModel');
    }

    // Robust way to read the security pin, converting it to string if necessary
    String? pin;
    if (data.containsKey('securityPin') && data['securityPin'] != null) {
      pin = data['securityPin'].toString();
    }

    return Empleado(
      id: documentId,
      nombre: data['nombre'] ?? 'Nombre no encontrado',
      apellido: data['apellido'] ?? '',
      email: data['email'] ?? 'Email no encontrado',
      cargo: parsedCargo,
      rut: data['rut'] ?? 'RUT no encontrado',
      telefono: data['telefono']?.toString() ?? 'Teléfono no encontrado',
      securityPin: pin,
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
      if (securityPin != null) 'securityPin': securityPin,
    };
  }
}

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

  // Getter to combine first and last name
  String get nombreCompleto => '$nombre $apellido';

  factory Empleado.fromMap(Map<String, dynamic> data, String documentId) {
    // Safely parse the 'cargo' field
    String cargoData = data['cargo'] ?? 'N/A';
    if (cargoData.contains('/')) {
      cargoData = cargoData.split('/').last;
    }

    return Empleado(
      id: documentId,
      nombre: data['nombre'] ?? 'Nombre no encontrado',
      apellido: data['apellido'] ?? '', // Read the last name
      email: data['email'] ?? 'Email no encontrado',
      cargo: cargoData, // Use the cleaned cargo data
      rut: data['rut'] ?? 'RUT no encontrado',
      telefono: data['telefono'] ?? 'Teléfono no encontrado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'cargo': '/cargo/$cargo', // Save it back in the original format if needed
      'rut': rut,
      'telefono': telefono,
    };
  }
}

class Empleado {
  final String id;
  final String nombre;
  final String email;
  final String cargo;
  final String rut;
  final String telefono;

  Empleado({
    required this.id,
    required this.nombre,
    required this.email,
    required this.cargo,
    required this.rut,
    required this.telefono,
  });

  factory Empleado.fromMap(Map<String, dynamic> data, String documentId) {
    return Empleado(
      id: documentId,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      cargo: data['cargo'] ?? 'N/A',
      rut: data['rut'] ?? 'N/A',
      telefono: data['telefono'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'cargo': cargo,
      'rut': rut,
      'telefono': telefono,
    };
  }
}

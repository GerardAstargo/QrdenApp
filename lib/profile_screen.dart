import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/empleado_model.dart';
import 'services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Empleado?> _employeeFuture;
  final FirestoreService _dbService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  void _loadEmployeeData() {
    if (currentUser != null && currentUser!.email != null) {
      setState(() {
        _employeeFuture = _dbService.getEmployeeByEmail(currentUser!.email!);
      });
    } else {
      setState(() {
        _employeeFuture = Future.value(null);
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e, s) {
      developer.log('Error signing out', name: 'ProfileScreen', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Perfil de Empleado'),
      ),
      body: FutureBuilder<Empleado?>(
        future: _employeeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final employee = snapshot.data!;
            return _buildProfileView(context, employee);
          }
          return _buildInfoView(context, snapshot.error);
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, Empleado employee) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFE8EAF6),
            child: Icon(Icons.person, size: 50, color: Color(0xFF7986CB)),
          ),
          const SizedBox(height: 16),
          Text(
            employee.nombreCompleto, // Use the new getter for the full name
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            employee.cargo, // Display the cleaned cargo
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(context, Icons.email_outlined, 'Email', employee.email),
                  const Divider(height: 24),
                  _buildInfoRow(context, Icons.badge_outlined, 'RUT', employee.rut),
                  const Divider(height: 24),
                  _buildInfoRow(context, Icons.phone_outlined, 'Teléfono', employee.telefono),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoView(BuildContext context, Object? error) {
    String infoText;
    if (currentUser == null) {
      infoText = 'No hay ninguna sesión activa.';
    } else {
      // Provide a more detailed message
      infoText = 'No se encontró un perfil de empleado para el correo:\n${currentUser!.email}\n\nVerifica que el email de inicio de sesión coincida con el registrado en la base de datos.';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.person_search_sharp, color: Colors.grey[400], size: 80),
          const SizedBox(height: 20),
          Text(infoText, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.white),
      label: Text('Cerrar Sesión', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      onPressed: _signOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

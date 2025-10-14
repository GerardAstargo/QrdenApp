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
      // If there's no user, set the future to null immediately.
      setState(() {
        _employeeFuture = Future.value(null);
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // AuthWrapper will handle navigation.
    } catch (e, s) {
      developer.log('Error signing out', name: 'ProfileScreen', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Empleado?>(
          future: _employeeFuture,
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Data Loaded Successfully
            if (snapshot.hasData && snapshot.data != null) {
              final employee = snapshot.data!;
              return _buildProfileView(context, employee);
            }

            // 3. Error or No Data Found State
            return _buildInfoView(context, snapshot.error);
          },
        ),
      ),
    );
  }

  // Widget for displaying the employee's profile
  Widget _buildProfileView(BuildContext context, Empleado employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              children: [
                Icon(Icons.account_circle, size: 90, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  employee.nombre,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  employee.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        _buildSignOutButton(),
      ],
    );
  }

  // Widget for showing info (error, no data, or logged out)
  Widget _buildInfoView(BuildContext context, Object? error) {
    String infoText;
    if (currentUser == null) {
      infoText = 'No hay ninguna sesión activa.';
    } else if (error != null) {
      infoText = 'Ocurrió un error al cargar tu perfil.';
    } else {
      infoText = 'No se encontró un perfil de empleado para el correo:\n${currentUser!.email}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, color: Colors.grey[400], size: 80),
        const SizedBox(height: 20),
        Text(
          infoText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 30),
        _buildSignOutButton(),
      ],
    );
  }

  // Themed Sign-Out Button
  Widget _buildSignOutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('Cerrar Sesión'),
      onPressed: _signOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

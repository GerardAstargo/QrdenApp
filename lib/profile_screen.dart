import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'models/empleado_model.dart';
import 'services/firestore_service.dart';
import 'theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Empleado?> _employeeFuture;
  final FirestoreService _dbService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  void _loadEmployeeData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        _employeeFuture = _dbService.getEmployeeByEmail(user.email!);
      });
    } else {
      setState(() {
        _employeeFuture = Future.value(null);
      });
    }
  }

  // This is the correct, bug-free _signOut method
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // No navigation logic is needed here. 
      // The AuthWrapper in main.dart handles redirecting to the LoginScreen.
    } catch (e, s) {
      developer.log('Error signing out', name: 'ProfileScreen', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Empleado'),
      ),
      body: FutureBuilder<Empleado?>(
        future: _employeeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.data.hasData || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudieron cargar los datos del empleado o no hay una sesión activa.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      onPressed: _signOut,
                    ),
                  ],
                ),
              ),
            );
          }

          final employee = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.person_pin, size: 80, color: Colors.deepPurple),
                        const SizedBox(height: 16),
                        Text(
                          employee.nombre,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _ ){
                        return SwitchListTile(
                        title: const Text('Modo Oscuro'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                            themeProvider.toggleTheme(value);
                        },
                        secondary: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        ),
                      );
                    }
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

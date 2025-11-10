import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

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
      // If there is no user, set the future to null to handle it gracefully
      setState(() {
        _employeeFuture = Future.value(null);
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, you might want to navigate to the login screen
      // or update the UI accordingly. For now, we'll just log it.
      developer.log('User signed out successfully', name: 'ProfileScreen');
    } catch (e, s) {
      developer.log('Error signing out', name: 'ProfileScreen', error: e, stackTrace: s);
    }
  }

  Future<void> _showPinDialog(Empleado employee) async {
    final formKey = GlobalKey<FormState>();
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(employee.hasPin ? 'Cambiar PIN de Seguridad' : 'Crear PIN de Seguridad'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  const Text('El PIN debe contener exactamente 6 dígitos numéricos.'),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: pinController,
                    decoration: const InputDecoration(labelText: 'Nuevo PIN', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.length != 6) {
                        return 'El PIN debe tener 6 dígitos';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Solo se permiten números';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmPinController,
                    decoration: const InputDecoration(labelText: 'Confirmar PIN', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    validator: (value) {
                      if (value != pinController.text) {
                        return 'Los PINs no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _dbService.updateSecurityPin(employee.id, pinController.text);
                    Navigator.of(context).pop(); // Close dialog on success
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN actualizado con éxito'), backgroundColor: Colors.green),
                    );
                    _loadEmployeeData(); // Refresh profile data
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar el PIN: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Perfil de Empleado'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Empleado?>(
        future: _employeeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            developer.log('Error in FutureBuilder', error: snapshot.error, stackTrace: snapshot.stackTrace);
            return _buildErrorView(context, 'Ocurrió un error al cargar el perfil.');
          }
          if (snapshot.hasData && snapshot.data != null) {
            return _buildProfileView(context, snapshot.data!);
          }
          return _buildErrorView(context, 'No se encontró un perfil para \n${currentUser?.email ?? "el usuario actual"}.');
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, Empleado employee) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white70,
            child: Icon(Icons.person, size: 60, color: Colors.deepPurple),
          ),
          const SizedBox(height: 12),
          Text(
            employee.nombreCompleto,
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            employee.cargo,
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _buildInfoCard(context, employee),
                    const SizedBox(height: 20),
                    _buildPinButton(context, employee), // PIN Button
                    const SizedBox(height: 20),
                    _buildSignOutButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Empleado employee) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow(context, Icons.email_outlined, 'Email', employee.email),
            const Divider(height: 30),
            _buildInfoRow(context, Icons.badge_outlined, 'RUT', employee.rut),
            const Divider(height: 30),
            _buildInfoRow(context, Icons.phone_outlined, 'Teléfono', employee.telefono),
            const Divider(height: 30),
            _buildInfoRow(context, Icons.shield_outlined, 'PIN de Seguridad', employee.hasPin ? '******' : 'No establecido'),

          ],
        ),
      ),
    );
  }

  Widget _buildPinButton(BuildContext context, Empleado employee) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.lock_person_sharp),
      label: Text(employee.hasPin ? 'Cambiar PIN' : 'Crear PIN'),
      onPressed: () => _showPinDialog(employee),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        backgroundColor: Colors.deepPurple.shade50,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 80),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.white),
      label: Text('Cerrar Sesión', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      onPressed: _signOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        shadowColor: Colors.red.withAlpha(102),
      ),
    );
  }
}

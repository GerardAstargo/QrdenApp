import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:qrden/login_screen.dart';
import 'package:qrden/services/firestore_service.dart';
import 'package:qrden/models/empleado_model.dart';
import 'dart:developer' as developer;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<Empleado?> _employeeFuture;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  void _loadEmployeeData() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        _employeeFuture = _firestoreService.getEmployeeByEmail(user.email!);
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
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
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
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudieron cargar los datos del empleado.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Asegúrate de que el usuario esté registrado en la colección 'empleados' de Firestore con un correo electrónico válido.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final empleado = snapshot.data!;

          return AnimationLimiter(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildHeader(context, empleado),
                  const SizedBox(height: 24),
                  _buildProfileCard(context, empleado),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Empleado empleado) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: colorScheme.primary.withAlpha(25),
          child: Icon(Icons.person, size: 60, color: colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          '${empleado.nombre} ${empleado.apellido}',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        if (empleado.cargo != null)
          FutureBuilder<DocumentSnapshot>(
            future: empleado.cargo!.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return const SizedBox.shrink();
              }
              final cargoData = snapshot.data!.data() as Map<String, dynamic>?;
              final cargoNombre = cargoData?['nombrecargo'] as String? ?? 'Cargo no especificado';

              return Text(
                cargoNombre,
                style: textTheme.titleMedium?.copyWith(color: colorScheme.secondary),
              );
            },
          )
        else
          Text(
            'Sin cargo asignado',
            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, Empleado empleado) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailItem(context, Icons.email_outlined, 'Email', empleado.email),
            _buildDetailItem(context, Icons.badge_outlined, 'RUT', empleado.rut),
            _buildDetailItem(context, Icons.phone_outlined, 'Teléfono', empleado.telefono),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

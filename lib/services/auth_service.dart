import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrden/models/empleado_model.dart';
import 'package:qrden/pin_screen.dart';
import 'package:qrden/services/firestore_service.dart';
import '../login_screen.dart';
import 'dart:developer' as developer;

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se verifica el estado de autenticación, muestra un cargador
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final User? user = snapshot.data;

        if (user == null) {
          // Si no hay usuario, muestra la pantalla de inicio de sesión
          return const LoginScreen();
        } else {
          // Si HAY un usuario, no vayas a HomeScreen. Valida su perfil de empleado primero.
          return _EmployeeProfileValidator(user: user);
        }
      },
    );
  }
}

// Este widget valida si un usuario autenticado tiene un perfil en la base de datos.
class _EmployeeProfileValidator extends StatefulWidget {
  final User user;
  const _EmployeeProfileValidator({required this.user});

  @override
  State<_EmployeeProfileValidator> createState() => _EmployeeProfileValidatorState();
}

class _EmployeeProfileValidatorState extends State<_EmployeeProfileValidator> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<Empleado?> _getEmployeeProfile() {
    if (widget.user.email == null) {
      developer.log('Error: Usuario de Firebase no tiene email.', name: 'AuthWrapper');
      return Future.value(null);
    }
    return _firestoreService.getEmployeeByEmail(widget.user.email!);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Empleado?>(
      future: _getEmployeeProfile(),
      builder: (context, snapshot) {
        // Mientras se busca el perfil del empleado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          developer.log('Error al buscar perfil de empleado, cerrando sesión', error: snapshot.error, name: 'AuthWrapper');
          _signOut(); 
          return const LoginScreen(); 
        }

        final Empleado? employee = snapshot.data;

        if (employee != null) {
          // ¡Perfil encontrado! Redirige a la pantalla del PIN.
          developer.log('Usuario autenticado, perfil encontrado. Redirigiendo a PinScreen.', name: 'AuthWrapper');
          return PinScreen(employee: employee);
        } else {
          // ¡Perfil NO encontrado! Esto es un problema. Cierra la sesión y envía a Login.
          developer.log('Usuario autenticado pero sin perfil en Firestore. Cerrando sesión.', name: 'AuthWrapper');
          _signOut();
          // Podrías pasar un mensaje de error a la pantalla de login si quisieras.
          return const LoginScreen();
        }
      },
    );
  }
}

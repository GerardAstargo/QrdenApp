import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:developer' as developer;

import 'pin_screen.dart';
import 'services/firestore_service.dart';
import 'models/empleado_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        final Empleado? employee = await _firestoreService.getEmployeeByEmail(user.email!);

        if (!mounted) return;

        if (employee != null) {
          // Si se encuentra al empleado, SIEMPRE redirige a la pantalla del PIN.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PinScreen(employee: employee)),
          );
        } else {
          // Si NO se encuentra un perfil de empleado, cierra sesión y muestra un error.
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage = 'No se encontró un perfil de empleado para este correo. Contacte a un administrador.';
            _isLoading = false;
          });
          developer.log(
            'Inicio de sesión fallido: No se encontró perfil de empleado para ${user.email}',
            name: 'LoginScreenLogic',
          );
        }
      }
    } on FirebaseAuthException {
      setState(() {
        _errorMessage = 'Correo o contraseña incorrectos.';
      });
    } catch (e, s) {
      developer.log('Error en el login: $e', stackTrace: s, name: 'LoginScreenDebug');
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado.';
      });
    } finally {
      if (mounted && _errorMessage == null) {
        // Solo detiene la carga si no se manejó un error que ya lo hace.
      } else if (mounted && _errorMessage != null) {
         setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AnimationLimiter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 60,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Qrden',
                          textAlign: TextAlign.center,
                          style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestiona tu inventario fácilmente',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Correo Electrónico', prefixIcon: Icon(Icons.email_outlined)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value?.isEmpty ?? true) ? 'Ingresa tu correo' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                          obscureText: true,
                          validator: (value) => (value?.isEmpty ?? true) ? 'Ingresa tu contraseña' : null,
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 32),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _login,
                                child: const Text('Iniciar Sesión'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

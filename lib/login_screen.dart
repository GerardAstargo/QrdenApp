import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:developer' as developer;

import 'home_screen.dart'; // Import HomeScreen

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
  bool _keepLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Check if a user is already logged in
    if (FirebaseAuth.instance.currentUser != null) {
      // If so, navigate to home screen immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    }
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.setPersistence(
        _keepLoggedIn ? Persistence.LOCAL : Persistence.SESSION,
      );

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      final user = userCredential.user;
      if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
        final displayName = _emailController.text.split('@').first;
        await user.updateDisplayName(displayName);
      }
      
      // After login, navigate to home screen
      if(mounted){
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }

    } on FirebaseAuthException {
      if (mounted) {
        setState(() {
          _errorMessage = 'Correo o contraseña incorrectos.';
        });
      }
    } catch (e, s) {
      developer.log('Login failed with unexpected error', name: 'LoginScreen', error: e, stackTrace: s);
      if (mounted) {
        setState(() {
          _errorMessage = 'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
        });
      }
    } finally {
      if (mounted) {
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
                        Icon(
                          Icons.qr_code_scanner,
                          size: 60,
                          color: colorScheme.primary,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CheckboxListTile(
                            title: const Text("Mantener sesión iniciada"),
                            value: _keepLoggedIn,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _keepLoggedIn = newValue;
                                });
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 24),
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

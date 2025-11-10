import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrden/services/firestore_service.dart';
import 'models/empleado_model.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'dart:developer' as developer;

class PinScreen extends StatefulWidget {
  final Empleado employee;

  const PinScreen({super.key, required this.employee});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;
  bool _isCreatingPin = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _isCreatingPin = !widget.employee.hasPin;
  }

  Future<void> _handlePinAction() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _errorText = null;
    });

    final pin = _pinController.text;

    if (_isCreatingPin) {
      // Lógica para crear un nuevo PIN
      try {
        await _firestoreService.updateSecurityPin(widget.employee.id, pin);
        developer.log('PIN creado con éxito para ${widget.employee.id}', name: 'PinScreen');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡PIN creado con éxito!')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        developer.log('Error al crear el PIN: $e', name: 'PinScreen', error: e);
        setState(() {
          _errorText = 'No se pudo guardar el PIN. Inténtalo de nuevo.';
        });
      }
    } else {
      // Lógica para verificar el PIN existente
      if (pin == widget.employee.securityPin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _errorText = 'PIN incorrecto. Inténtalo de nuevo.';
        });
        _pinController.clear();
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isCreatingPin ? 'Crea tu PIN de Seguridad' : 'Verificación de Seguridad';
    final subtitle = _isCreatingPin
        ? 'Hola, ${widget.employee.nombre}. Crea un PIN de 6 dígitos para proteger tu cuenta.'
        : 'Hola, ${widget.employee.nombre}. Ingresa tu PIN de 6 dígitos.';
    final buttonText = _isCreatingPin ? 'Guardar y Continuar' : 'Verificar e Ingresar';

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shield_moon_outlined,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _pinController,
                  maxLength: 6,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 18),
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'PIN de 6 dígitos',
                    errorText: _errorText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return 'El PIN debe contener exactamente 6 dígitos.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _handlePinAction,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonText),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _logout,
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

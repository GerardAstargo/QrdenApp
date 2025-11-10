import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/empleado_model.dart';
import 'home_screen.dart';

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

  void _verifyPin() {
    setState(() {
      _errorText = null;
    });

    if (_formKey.currentState!.validate()) {
      if (_pinController.text == widget.employee.securityPin) {
        // Navigate to home on success
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Show error on failure
        setState(() {
          _errorText = 'PIN incorrecto. Inténtalo de nuevo.';
        });
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                Icon(
                  Icons.shield_moon_outlined,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                Text(
                  'Verificación de Seguridad',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hola, ${widget.employee.nombre}. Ingresa tu PIN de 6 dígitos.',
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
                    labelText: 'PIN de Seguridad',
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
                      return 'El PIN debe contener 6 dígitos.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _verifyPin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Verificar e Ingresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

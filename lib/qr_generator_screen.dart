import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import './firestore_service.dart'; // Import FirestoreService

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String _qrData = '';
  final FirestoreService _firestoreService = FirestoreService(); // Instantiate the service

  @override
  void initState() {
    super.initState();
    _generateAndSaveQrCode();
  }

  // Renamed to reflect the new save functionality
  Future<void> _generateAndSaveQrCode() async {
    final random = Random();
    // Generate a random 12-digit number as a string
    final randomNumber = List.generate(12, (_) => random.nextInt(10)).join();
    
    // Update the UI first for a responsive feel
    if (mounted) {
      setState(() {
        _qrData = randomNumber;
      });
    }

    // Asynchronously save the new QR code to Firestore
    try {
      await _firestoreService.saveGeneratedQr(randomNumber);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el código QR: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Código QR'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Código Generado:',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            // Show a placeholder if QR data is not yet generated
            if (_qrData.isNotEmpty)
              Text(
                _qrData,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(128),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  // Only build the QrImageView if there is data
                  child: _qrData.isNotEmpty
                      ? QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 250.0,
                          gapless: false,
                        )
                      : const CircularProgressIndicator(), // Show a loader initially
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Generar Nuevo Código'),
              onPressed: _generateAndSaveQrCode, // Call the updated function
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

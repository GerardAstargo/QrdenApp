import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String _qrData = ''; // Holds the data for the current QR code

  // Function to generate a new random QR code
  void _generateQrCode() {
    final random = Random();
    // Generate a 12-digit random number as a string
    final randomNumber = List.generate(12, (_) => random.nextInt(10)).join();
    setState(() {
      _qrData = randomNumber;
    });
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
            // Text to show the generated code
            if (_qrData.isNotEmpty)
              Column(
                children: [
                  const Text(
                    'Código generado:',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _qrData,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // QR code display area
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _qrData.isNotEmpty
                        ? [
                            BoxShadow(
                              color: Colors.grey.withAlpha(128),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: _qrData.isEmpty
                      ? const Center(
                          child: Text(
                          'Presiona el botón para generar un código',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ))
                      : QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 250.0,
                          gapless: false,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Button to generate a new code
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Generar Nuevo Código'),
              onPressed: _generateQrCode,
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

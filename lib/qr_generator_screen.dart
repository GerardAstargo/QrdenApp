import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import './firestore_service.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String _qrData = '';
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey _qrKey = GlobalKey(); // Key to capture the QR widget
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Generate the first code when the screen loads
    _generateAndSaveQrCode();
  }

  Future<void> _generateAndSaveQrCode() async {
    if (_isLoading) return; // Prevent multiple simultaneous operations

    if (mounted) {
      setState(() {
        _isLoading = true;
        _qrData = ''; // Clear previous QR while generating
      });
    }

    final random = Random();
    final randomNumber = List.generate(12, (_) => random.nextInt(10)).join();

    // Set the new QR data and let the UI rebuild before capturing
    if (mounted) {
      setState(() {
        _qrData = randomNumber;
      });
    }

    // Wait for the widget to be rendered
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // 1. Capture the QR image
      final Uint8List? imageData = await _captureQrImage();
      if (imageData == null) {
        throw Exception("No se pudo capturar la imagen del código QR.");
      }

      // 2. Save image to Storage and data to Firestore
      await _firestoreService.saveGeneratedQrAndImage(randomNumber, imageData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código QR guardado correctamente.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List?> _captureQrImage() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
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
            // ... (Text widgets for code display)

            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: _qrKey, // Assign the key here
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _qrData.isNotEmpty ? [
                        BoxShadow(
                          color: Colors.grey.withAlpha(128),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ] : [],
                    ),
                    child: _isLoading || _qrData.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 250.0,
                            gapless: false,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.refresh),
              label: Text(_isLoading ? 'Guardando...' : 'Generar Nuevo Código'),
              onPressed: _generateAndSaveQrCode,
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

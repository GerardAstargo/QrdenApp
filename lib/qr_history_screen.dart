import 'dart:convert'; // Import for base64 decoding
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './firestore_service.dart';
import './qr_code_record_model.dart';

class QrHistoryScreen extends StatelessWidget {
  const QrHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Códigos QR'),
      ),
      body: StreamBuilder<List<QrCodeRecord>>(
        stream: firestoreService.getGeneratedQrs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay códigos QR generados todavía.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final qrCodes = snapshot.data!;

          return ListView.builder(
            itemCount: qrCodes.length,
            itemBuilder: (context, index) {
              final record = qrCodes[index];
              final formattedDate = DateFormat('dd/MM/yyyy, hh:mm a').format(record.generatedAt.toDate());

              // Function to decode the base64 string and return an Image widget
              Widget qrImageWidget;
              if (record.imageBase64.isNotEmpty) {
                try {
                  // Decode the base64 string into image data
                  final Uint8List imageBytes = base64Decode(record.imageBase64);
                  // Display the image from memory
                  qrImageWidget = Image.memory(imageBytes, fit: BoxFit.cover);
                } catch (e) {
                  // If decoding fails, show an error icon
                  qrImageWidget = const Icon(Icons.error_outline, color: Colors.red, size: 40);
                }
              } else {
                // Placeholder if no image data is available
                qrImageWidget = const Icon(Icons.qr_code_2, size: 40, color: Colors.grey);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: qrImageWidget,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.code,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Generado: $formattedDate',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Display the QR image from the URL
                      if (record.imageUrl.isNotEmpty)
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(
                            record.imageUrl,
                            fit: BoxFit.cover,
                            // Show a loader while the image is loading
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            // Show an error icon if the image fails to load
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error_outline, color: Colors.red, size: 40);
                            },
                          ),
                        )
                      else
                        // Placeholder if no image URL is available
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.qr_code_2, size: 40, color: Colors.grey),
                        ),
                      const SizedBox(width: 16),
                      // Column for text content
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

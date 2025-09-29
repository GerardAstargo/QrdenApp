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
              // Format the timestamp to a readable date and time
              final formattedDate = DateFormat('dd/MM/yyyy, hh:mm a').format(record.generatedAt.toDate());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.qr_code_2, size: 40, color: Colors.blueGrey),
                  title: Text(
                    record.code,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'Generado: $formattedDate',
                    style: const TextStyle(color: Colors.grey),
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

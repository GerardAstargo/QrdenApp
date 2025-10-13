import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './history_model.dart';
import './firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: firestoreService.getHistoryEntries(),
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
                'No hay movimientos en el historial.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final entries = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              
              final bool isProductActive = entry.fechaSalida == null;
              final IconData icon = isProductActive ? Icons.file_download_done_rounded : Icons.archive_rounded;
              final Color color = isProductActive ? Colors.green.shade700 : Colors.red.shade700;
              final String statusText = isProductActive ? 'ACTIVO' : 'ARCHIVADO';

              final format = DateFormat('dd/MM/yy, HH:mm');
              final String fechaIngresoStr = format.format(entry.fechaIngreso.toDate());
              final String fechaSalidaStr = entry.fechaSalida != null 
                  ? format.format(entry.fechaSalida!.toDate())
                  : '--/--/--';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  // FIX: Replaced deprecated withOpacity with withAlpha
                  side: BorderSide(color: color.withAlpha(128), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: CircleAvatar(
                    // FIX: Replaced deprecated withOpacity with withAlpha
                    backgroundColor: color.withAlpha(38),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  title: Text(
                    entry.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Cant: ${entry.quantity} | Precio: \$${entry.price.toStringAsFixed(2)}\nIngreso: $fechaIngresoStr\nSalida:   $fechaSalidaStr',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    statusText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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

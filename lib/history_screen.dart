import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './history_model.dart';
import './firestore_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
      ),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: firestoreService.getHistoryEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Se produjo un error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay movimientos en el historial.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final entries = snapshot.data!;

          return AnimationLimiter(
            child: ListView.builder(
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

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: color.withAlpha(25),
                            child: Icon(icon, color: color, size: 28),
                          ),
                          title: Text(
                            entry.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          // --- REVERTED: Use productId which holds the QR Code ---
                          subtitle: Text(
                            'QR: ${entry.productId}\nCant: ${entry.quantity} | Ingreso: $fechaIngresoStr | Salida: $fechaSalidaStr',
                            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
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
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

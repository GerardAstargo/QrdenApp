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
              final isEntry = entry.accion == 'entrada';
              final icon = isEntry ? Icons.arrow_downward : Icons.arrow_upward;
              final color = isEntry ? Colors.green : Colors.red;
              final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(entry.fechaMovimiento.toDate());

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: Icon(icon, color: Colors.white),
                  ),
                  title: Text(
                    entry.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Cantidad: ${entry.quantity} | Precio: \$${entry.price.toStringAsFixed(2)}\nFecha: $formattedDate',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    entry.accion.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

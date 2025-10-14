
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/history_model.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _clearHistory() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas borrar todo el historial? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Borrar'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (!mounted) return; // Check if the widget is still in the tree

    if (confirm) {
      try {
        await _firestoreService.clearHistory();
        if (!mounted) return; // Re-check after the async operation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial borrado con éxito.')),
        );
      } catch (e) {
        if (!mounted) return; // And also in the catch block
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar el historial: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Borrar Historial',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: _firestoreService.getHistoryEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay movimientos registrados',
                    style: textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las entradas y salidas de productos aparecerán aquí.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data!;

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                
                final bool isProductActive = entry.fechaSalida == null;
                final Color statusColor = isProductActive ? Colors.green.shade700 : colorScheme.error;
                final IconData icon = isProductActive ? Icons.file_download_done_rounded : Icons.archive_outlined;
                final String statusText = isProductActive ? 'ACTIVO' : 'ARCHIVADO';

                final format = DateFormat('dd/MM/yy, HH:mm');
                final String fechaIngresoStr = format.format(entry.fechaIngreso.toDate());
                final String fechaSalidaStr = entry.fechaSalida != null 
                    ? format.format(entry.fechaSalida!.toDate())
                    : '--/--/--';

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 70.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 3.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: statusColor.withAlpha(25),
                            child: Icon(icon, color: statusColor, size: 28),
                          ),
                          title: Text(entry.name, style: textTheme.titleLarge),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cant: ${entry.quantity} | Precio: \$${entry.price.toStringAsFixed(2)}', style: textTheme.bodyMedium),
                                const SizedBox(height: 6),
                                Text('Ingreso: $fechaIngresoStr', style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                Text('Salida:   $fechaSalidaStr', style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Chip(
                            label: Text(statusText, style: textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                            backgroundColor: statusColor.withAlpha(38),
                            side: BorderSide(color: statusColor.withAlpha(76)),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

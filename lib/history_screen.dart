import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
import './firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Cambios'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el historial'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay historial para mostrar.'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final entry = docs[index].data() as Map<String, dynamic>;
              final timestamp = (entry['timestamp'] as Timestamp?)?.toDate();
              
              String formattedDate;
              if (timestamp != null) {
                formattedDate = Jiffy.parseFromDateTime(timestamp).fromNow();
              } else {
                formattedDate = 'Fecha desconocida';
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(entry['action'] ?? 'Acción desconocida'),
                  subtitle: Text('Por: ${entry['user'] ?? 'N/A'} - $formattedDate'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// A widget that takes a DocumentReference and displays a specific field from it.
class CategoryDisplayWidget extends StatelessWidget {
  final DocumentReference? categoryReference;

  const CategoryDisplayWidget({super.key, required this.categoryReference});

  @override
  Widget build(BuildContext context) {
    // If the reference is null, display a default text
    if (categoryReference == null) {
      return const Text('Sin categoría', style: TextStyle(color: Colors.grey));
    }

    // Use a FutureBuilder to fetch the data from the reference
    return FutureBuilder<DocumentSnapshot>(
      future: categoryReference!.get(),
      builder: (context, snapshot) {
        // While waiting for the data, show a placeholder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Cargando...', style: TextStyle(color: Colors.grey));
        }

        // If there's an error, display an error message
        if (snapshot.hasError) {
          return const Text('Error', style: TextStyle(color: Colors.red));
        }

        // If data is successfully fetched, display the category name
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          // The category document has a 'nombrecategoria' field
          final categoryName = data['nombrecategoria'] ?? 'Categoría desconocida'; 
          return Text(categoryName);
        }

        // If the document doesn't exist, show a default text
        return const Text('Sin categoría', style: TextStyle(color: Colors.grey));
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// A widget that takes a DocumentReference and displays a specific field from it.
class CategoryDisplayWidget extends StatelessWidget {
  final DocumentReference? categoryReference;
  final TextStyle? style; // Optional style parameter

  const CategoryDisplayWidget({super.key, required this.categoryReference, this.style});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    if (categoryReference == null) {
      return Text('Sin categoría', style: defaultStyle?.copyWith(color: Colors.grey));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: categoryReference!.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Cargando...', style: defaultStyle?.copyWith(color: Colors.grey));
        }

        if (snapshot.hasError) {
          return Text('Error', style: defaultStyle?.copyWith(color: Colors.red));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final categoryName = data['nombrecategoria'] ?? 'Categoría desconocida';
          return Text(categoryName, style: defaultStyle);
        }

        return Text('Sin categoría', style: defaultStyle?.copyWith(color: Colors.grey));
      },
    );
  }
}

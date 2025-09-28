import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Package to format the date
import './product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  // Helper function to format the timestamp
  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha no disponible';
    // Using a readable format
    return DateFormat('d MMM y, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Corrected: product.id
                _buildDetailRow(context, icon: Icons.qr_code, label: 'Código QR', value: product.id),
                const Divider(),
                _buildDetailRow(context, icon: Icons.category, label: 'Categoría', value: product.description),
                const Divider(),
                _buildDetailRow(context, icon: Icons.inventory_2, label: 'Stock', value: product.quantity.toString()),
                const Divider(),
                // Corrected: product.price
                _buildDetailRow(context, icon: Icons.price_change, label: 'Precio', value: '\$${product.price.toStringAsFixed(2)}'),
                const Divider(),
                // Corrected: product.fechaIngreso
                _buildDetailRow(context, icon: Icons.calendar_today, label: 'Fecha de Ingreso', value: _formatDate(product.fechaIngreso?.toDate())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistent detail rows
  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

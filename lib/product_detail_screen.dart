import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import './firestore_service.dart';
import './product_model.dart';
import './category_display_widget.dart';
import './scanner_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  Future<void> _deleteProduct(BuildContext context) async {
    final navigator = Navigator.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar permanentemente el producto \'${product.name}\'? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirestoreService().deleteProduct(product.id, product.name);
      navigator.pop();
    }
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          scanMode: 'edit',
          productToEdit: product,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modificar Producto',
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar Producto',
            onPressed: () => _deleteProduct(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: QrImageView(
                    data: product.id,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    final formattedDate = product.fechaIngreso != null
        ? DateFormat('dd/MM/yyyy, HH:mm').format(product.fechaIngreso!.toDate())
        : 'No disponible';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildInfoRow(context, 'Stock:', '${product.quantity} unidades', icon: Icons.inventory_2),
            const Divider(),
            _buildInfoRow(context, 'Precio:', NumberFormat.simpleCurrency().format(product.price), icon: Icons.attach_money),
            const Divider(),
            if (product.category != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(children: [ const Icon(Icons.category, color: Colors.grey, size: 20), const SizedBox(width: 16), CategoryDisplayWidget(categoryReference: product.category!) ])
              ),
            const Divider(),
            _buildInfoRow(context, 'Nº Estante:', product.numeroEstante ?? 'No asignado', icon: Icons.shelves),
            const Divider(),
            _buildInfoRow(context, 'Fecha Ingreso:', formattedDate, icon: Icons.calendar_today),
            const Divider(),
            _buildInfoRow(context, 'Ingresado por:', product.enteredBy ?? 'Desconocido', icon: Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {required IconData icon}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Text('$label ', style: textTheme.titleMedium),
          const Spacer(),
          Flexible(child: Text(value, style: textTheme.bodyLarge, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

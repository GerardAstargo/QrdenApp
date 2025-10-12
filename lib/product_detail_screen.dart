import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './product_model.dart';
import './firestore_service.dart';
import './category_display_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product; 

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _archiveProduct() async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archivar Producto'),
        content: Text('¿Estás seguro de que quieres archivar "${_product.name}"? Esta acción registrará su salida del inventario.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archivar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (shouldArchive) {
      await FirestoreService().archiveProduct(_product.id);
      if (mounted) {
        Navigator.pop(context, 'Producto archivado con éxito');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archivar Producto',
            onPressed: _archiveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDetailCard('Información General', [
              _buildInfoRow(Icons.qr_code, 'QR Code', _product.id),
              _buildInfoRow(Icons.label, 'Nombre', _product.name),
              _buildInfoRow(Icons.inventory, 'Stock Actual', _product.quantity.toString()),
              _buildInfoRow(Icons.sell, 'Precio', 'S/ ${_product.price.toStringAsFixed(2)}'),
              _buildInfoRow(Icons.storage, 'Nº de Estante', _product.numeroEstante ?? 'No especificado'),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard('Categoría', [
              _product.category != null 
                ? CategoryDisplayWidget(categoryReference: _product.category!) 
                : const Text('No especificada'),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard('Registro', [
              _buildInfoRow(Icons.person, 'Ingresado por', _product.enteredBy ?? 'Desconocido'),
              _buildInfoRow(
                Icons.calendar_today,
                'Fecha de Ingreso',
                _product.fechaIngreso != null ? dateFormat.format(_product.fechaIngreso!.toDate()) : 'No registrada',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

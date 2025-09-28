import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_service.dart';
import './product_model.dart';
import './edit_product_screen.dart'; // Import the new edit screen

enum ScanMode { add, remove, update }

class ScannerScreen extends StatefulWidget {
  final ScanMode scanMode;

  const ScannerScreen({super.key, required this.scanMode});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle())),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_isProcessing) return;
          setState(() {
            _isProcessing = true;
          });

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String qrCode = barcodes.first.rawValue ?? '';
            if (qrCode.isNotEmpty) {
              await _handleQrCode(qrCode);
            }
          }
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.scanMode) {
      case ScanMode.add:
        return 'Escanear para Añadir';
      case ScanMode.remove:
        return 'Escanear para Eliminar';
      case ScanMode.update:
        return 'Escanear para Modificar';
    }
  }

  Future<void> _handleQrCode(String qrCode) async {
    if (!mounted) return;

    switch (widget.scanMode) {
      case ScanMode.add:
        await _addProduct(qrCode);
        break;
      case ScanMode.remove:
        await _removeProduct(qrCode);
        break;
      case ScanMode.update:
        await _navigateToEditScreen(qrCode);
        break;
    }
  }

  Future<void> _addProduct(String qrCode) async {
    final existingProduct = await _firestoreService.getProductById(qrCode);
    if (!mounted) return;

    if (existingProduct != null) {
      _showErrorDialog('El producto con este código QR ya existe.');
      return;
    }

    final details = await _showProductDetailsDialog();
    if (!mounted) return;

    if (details != null) {
      // Using the corrected Product model
      final newProduct = Product(
        id: qrCode,
        name: details['name'],
        description: details['description'],
        quantity: details['quantity'],
        price: details['price'], // Corrected field name
        fechaIngreso: Timestamp.now(),
      );
      await _firestoreService.addProduct(newProduct);
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _removeProduct(String qrCode) async {
    final existingProduct = await _firestoreService.getProductById(qrCode);
    if (!mounted) return;

    if (existingProduct == null) {
      _showErrorDialog('El producto no existe y no puede ser eliminado.');
      return;
    }

    await _firestoreService.deleteProduct(qrCode);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
    Navigator.of(context).pop();
  }

  Future<void> _navigateToEditScreen(String qrCode) async {
    final productToEdit = await _firestoreService.getProductById(qrCode);
    if (!mounted) return;

    if (productToEdit == null) {
      _showErrorDialog('El producto no existe y no puede ser modificado.');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: productToEdit),
      ),
    );

    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  Future<Map<String, dynamic>?> _showProductDetailsDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Nuevo Producto'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Categoría'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                TextFormField(controller: quantityController, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                TextFormField(controller: priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'quantity': int.tryParse(quantityController.text) ?? 0,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                });
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }
}

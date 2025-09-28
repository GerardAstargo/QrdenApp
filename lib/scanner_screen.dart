import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import './firestore_service.dart';
import './product_model.dart';

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
    switch (widget.scanMode) {
      case ScanMode.add:
        await _addProduct(qrCode);
        break;
      case ScanMode.remove:
        await _removeProduct(qrCode);
        break;
      case ScanMode.update:
        await _updateProduct(qrCode);
        break;
    }
  }

  Future<void> _addProduct(String qrCode) async {
    final existingProduct = await _firestoreService.getProduct(qrCode);
    if (!mounted) return;
    if (existingProduct != null) {
      _showErrorDialog('El producto ya existe.');
      return;
    }

    final details = await _showProductDetailsDialog();
    if (!mounted) return;
    if (details != null) {
      // Updated to pass the new price field
      await _firestoreService.addProduct(
          qrCode, details['name'], details['description'], details['quantity'], details['price']);
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
       // If user cancels, stop processing
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _removeProduct(String qrCode) async {
    final existingProduct = await _firestoreService.getProduct(qrCode);
    if (!mounted) return;
    if (existingProduct == null) {
      _showErrorDialog('El producto no existe.');
      return;
    }

    await _firestoreService.deleteProduct(qrCode);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _updateProduct(String qrCode) async {
    final existingProduct = await _firestoreService.getProduct(qrCode);
    if (!mounted) return;
    if (existingProduct == null) {
      _showErrorDialog('El producto no existe.');
      return;
    }

    final newQuantity = await _showUpdateQuantityDialog(existingProduct);
    if (!mounted) return;
    if (newQuantity != null) {
      await _firestoreService.updateProductQuantity(qrCode, newQuantity);
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      // If user cancels, stop processing
      setState(() => _isProcessing = false);
    }
  }

  Future<Map<String, dynamic>?> _showProductDetailsDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController(); // Controller for price

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Categoría')),
              TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number),
              // Added price text field
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop({
                'name': nameController.text,
                'description': descriptionController.text,
                'quantity': int.tryParse(quantityController.text) ?? 0,
                // Passing price value
                'price': double.tryParse(priceController.text) ?? 0.0,
              });
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<int?> _showUpdateQuantityDialog(Product product) async {
    final TextEditingController quantityController = TextEditingController(text: product.quantity.toString());

    return showDialog<int?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Cantidad'),
        content: TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Nueva Cantidad'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(int.tryParse(quantityController.text));
            },
            child: const Text('Actualizar'),
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
      if(mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }
}

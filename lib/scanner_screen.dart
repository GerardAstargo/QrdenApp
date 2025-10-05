import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_service.dart';
import './product_model.dart';
import './edit_product_screen.dart';

enum ScanMode { add, remove, update }

class ScannerScreen extends StatefulWidget {
  final ScanMode scanMode;

  const ScannerScreen({super.key, required this.scanMode});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle())),
      body: MobileScanner(
        controller: _controller,
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
      final newProduct = Product(
        id: qrCode,
        name: details['name'],
        category: details['categoryRef'],
        quantity: details['quantity'],
        price: details['price'],
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

    final bool confirmed = await _showDeleteConfirmationDialog(existingProduct.name);
    if (confirmed) {
      await _firestoreService.deleteProduct(qrCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado correctamente')));
      Navigator.of(context).pop();
    } else {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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

  Future<bool> _showDeleteConfirmationDialog(String productName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text('¿Estás seguro de que deseas eliminar el producto "$productName"? Esta acción no se puede deshacer.'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<Map<String, dynamic>?> _showProductDetailsDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    DocumentReference? selectedCategoryRef;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Añadir Nuevo Producto'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                      const SizedBox(height: 16),
                      StreamBuilder<List<DocumentSnapshot>>(
                        stream: _firestoreService.getCategories(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final categories = snapshot.data!;
                          return DropdownButtonFormField<DocumentReference>(
                            isExpanded: true, // Solución #1
                            decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                            hint: const Text('Selecciona una categoría'),
                            value: selectedCategoryRef,
                            items: categories.map((doc) {
                              final categoryName = (doc.data() as Map<String, dynamic>)['nombrecategoria'] ?? 'Sin nombre';
                              return DropdownMenuItem<DocumentReference>(
                                value: doc.reference,
                                child: Text(
                                  categoryName,
                                  overflow: TextOverflow.ellipsis, // Solución #2
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategoryRef = value;
                              });
                            },
                            validator: (v) => v == null ? 'Requerido' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
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
                        'categoryRef': selectedCategoryRef,
                        'quantity': int.tryParse(quantityController.text) ?? 0,
                        'price': double.tryParse(priceController.text) ?? 0.0,
                      });
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
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

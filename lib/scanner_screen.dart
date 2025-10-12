import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import './firestore_service.dart';
import './product_model.dart';

class ScannerScreen extends StatefulWidget {
  final String scanMode;
  final Product? productToEdit;

  const ScannerScreen({super.key, required this.scanMode, this.productToEdit});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _shelfController;
  DocumentReference? _selectedCategory;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productToEdit != null;

    _nameController = TextEditingController(text: _isEditMode ? widget.productToEdit!.name : '');
    _quantityController = TextEditingController(text: _isEditMode ? widget.productToEdit!.quantity.toString() : '1');
    _priceController = TextEditingController(text: _isEditMode ? widget.productToEdit!.price.toString() : '');
    _shelfController = TextEditingController(text: _isEditMode ? widget.productToEdit!.numeroEstante ?? '' : '');
    _selectedCategory = _isEditMode ? widget.productToEdit!.category : null;
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _shelfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modificar Producto' : 'Escanear Código QR'),
      ),
      body: _isEditMode
          ? _buildEditForm()
          : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
      controller: _scannerController,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final String? code = barcodes.first.rawValue;
          if (code != null) {
            _scannerController.stop();
            _handleScan(code);
          }
        }
      },
    );
  }

  Future<void> _handleScan(String code) async {
    final existingProduct = await _firestoreService.getProductById(code);

    if (!mounted) return;

    if (widget.scanMode == 'add' || widget.scanMode == 'update') {
      if (existingProduct != null) {
        _showAddStockDialog(existingProduct);
      } else {
        _showProductForm(code);
      }
    }
  }

  void _showProductForm(String code, {Product? product}) {
    _nameController.text = product?.name ?? '';
    _quantityController.text = product?.quantity.toString() ?? '1';
    _priceController.text = product?.price.toString() ?? '';
    _shelfController.text = product?.numeroEstante ?? '';
    _selectedCategory = product?.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _buildProductForm(code, isEdit: product != null),
    ).whenComplete(() => _scannerController.start());
  }
  
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildProductForm(widget.productToEdit!.id, isEdit: true),
    );
  }

  void _showAddStockDialog(Product product) {
    final quantityController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Añadir Stock a ${product.name}'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad a añadir'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity > 0) {
                   final updatedProduct = Product(
                    id: product.id,
                    name: product.name,
                    quantity: product.quantity + quantity,
                    price: product.price,
                    category: product.category,
                    numeroEstante: product.numeroEstante,
                    fechaIngreso: product.fechaIngreso,
                    enteredBy: product.enteredBy,
                  );
                  await _firestoreService.addOrUpdateProduct(updatedProduct);
                  
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      _scannerController.start();
      if(mounted) Navigator.of(context).pop();
    });
  }

  Widget _buildProductForm(String code, {bool isEdit = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? 'Modificar Producto' : 'Nuevo Producto', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Introduce un nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                 validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce una cantidad';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) return 'La cantidad debe ser un número positivo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce un precio';
                  if (double.tryParse(value) == null || double.parse(value) < 0) return 'El precio debe ser un número positivo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
               StreamBuilder<List<DocumentSnapshot>>(
                stream: _firestoreService.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return DropdownButtonFormField<DocumentReference>(
                    initialValue: _selectedCategory,
                    items: snapshot.data!.map((DocumentSnapshot doc) {
                      return DropdownMenuItem<DocumentReference>(
                        value: doc.reference,
                        child: Text(doc['nombrecategoria'] ?? 'Sin nombre'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                     validator: (value) => value == null ? 'Selecciona una categoría' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shelfController,
                decoration: const InputDecoration(labelText: 'Nº de Estante', border: OutlineInputBorder()),
                 validator: (value) => value == null || value.isEmpty ? 'Introduce un número de estante' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _submitForm(code, isEdit),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text(isEdit ? 'Guardar Cambios' : 'Añadir Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(String code, bool isEdit) async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;

      final product = Product(
        id: code,
        name: _nameController.text,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _selectedCategory,
        numeroEstante: _shelfController.text,
        fechaIngreso: isEdit ? widget.productToEdit!.fechaIngreso : Timestamp.now(),
        enteredBy: isEdit ? widget.productToEdit!.enteredBy : (user?.email ?? 'Desconocido'),
      );

      if (isEdit) {
        await _firestoreService.updateProduct(product);
      } else {
        await _firestoreService.addOrUpdateProduct(product);
      }
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Pops the form
      if (isEdit) {
          Navigator.of(context).pop(); // Pops the detail screen to go back to the list
      }
    }
  }
}

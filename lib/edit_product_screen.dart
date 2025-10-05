import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import './firestore_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _enteredByController; // Controller for the employee's name
  DocumentReference? _selectedCategoryRef;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _enteredByController = TextEditingController(text: widget.product.enteredBy); // Initialize with existing value
    _selectedCategoryRef = widget.product.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _enteredByController.dispose(); // Dispose the new controller
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        category: _selectedCategoryRef,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        fechaIngreso: widget.product.fechaIngreso,
        enteredBy: _enteredByController.text, // Get value from the new controller
      );

      try {
        await _firestoreService.updateProduct(updatedProduct);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado con éxito')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el producto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) => value!.isEmpty ? 'Por favor, introduce un nombre' : null,
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty ? 'Por favor, introduce un precio' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Por favor, introduce el stock' : null,
              ),
              const SizedBox(height: 16),
              // New TextFormField for the employee's name
              TextFormField(
                controller: _enteredByController,
                decoration: const InputDecoration(labelText: 'Ingresado por'),
                validator: (value) => value!.isEmpty ? 'Por favor, introduce el nombre del empleado' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _firestoreService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error al cargar categorías');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = snapshot.data ?? [];

        return DropdownButtonFormField<DocumentReference>(
          value: _selectedCategoryRef,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Categoría',
            border: OutlineInputBorder(),
          ),
          hint: const Text('Selecciona una categoría'),
          items: categories.map((doc) {
            final categoryName = (doc.data() as Map<String, dynamic>)['nombrecategoria'] ?? 'Sin Nombre';
            return DropdownMenuItem<DocumentReference>(
              value: doc.reference,
              child: Text(
                categoryName,
                overflow: TextOverflow.ellipsis, // Esto evitará el desbordamiento
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryRef = value;
            });
          },
          validator: (value) => value == null ? 'Por favor, selecciona una categoría' : null,
        );
      },
    );
  }
}

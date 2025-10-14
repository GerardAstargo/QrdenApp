import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/firestore_service.dart';
import 'models/product_model.dart';

enum ScanMode { add, remove, update }

class ScannerScreen extends StatefulWidget {
  final ScanMode scanMode;
  const ScannerScreen({super.key, required this.scanMode});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  String get _title {
    switch (widget.scanMode) {
      case ScanMode.add: return 'Escanear para Añadir';
      case ScanMode.remove: return 'Escanear para Eliminar';
      case ScanMode.update: return 'Escanear para Modificar';
    }
  }

  Future<void> _handleBarcode(String barcode) async {
    if (!mounted || _isProcessing) return;
    setState(() => _isProcessing = true);

    final product = await _firestoreService.getProductByCode(barcode);

    if (!mounted) {
      setState(() => _isProcessing = false);
      return;
    }

    switch (widget.scanMode) {
      case ScanMode.add:
        if (product != null) {
          _showErrorDialog('Un producto con este código de barras ya existe.');
        } else {
          await _showProductForm(qrCode: barcode);
        }
        break;
      case ScanMode.update:
        if (product == null) {
          _showErrorDialog('No se encontró ningún producto con este código.');
        } else {
          await _showProductForm(product: product, qrCode: barcode);
        }
        break;
      case ScanMode.remove:
        if (product == null) {
          _showErrorDialog('No se encontró ningún producto con este código.');
        } else {
          await _showDeleteConfirmation(product);
        }
        break;
    }
  }

  Future<void> _showProductForm({String? qrCode, Product? product}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => ProductForm(scrollController: controller, product: product, qrCode: qrCode),
      ),
    );

    if (result == true && mounted) {
      final message = product == null ? 'Producto añadido con éxito' : 'Producto actualizado con éxito';
      Navigator.pop(context, message);
    } else {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _showDeleteConfirmation(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Seguro que quieres eliminar "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deleteProduct(product.name); // Use product name as ID
      if (mounted) {
        Navigator.pop(context, 'Producto eliminado con éxito');
      }
    } else {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    ).then((_) => setState(() => _isProcessing = false));
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final String? barcode = capture.barcodes.first.rawValue;
              if (barcode != null) _handleBarcode(barcode);
            },
          ),
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 12,
                borderLength: 24,
                borderWidth: 6,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _scannerController,
                    builder: (context, state, child) {
                      return IconButton(
                        onPressed: () => _scannerController.toggleTorch(),
                        icon: Icon(
                          state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                        iconSize: 32,
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    iconSize: 32,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = 0.8,
    this.borderRadius = 0,
    this.borderLength = 40,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path()..addRect(Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) => Path()..moveTo(rect.left, rect.bottom)..lineTo(rect.left, rect.top)..lineTo(rect.right, rect.top);
    return getLeftTopPath(rect)..lineTo(rect.right, rect.bottom)..lineTo(rect.left, rect.bottom)..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final h = (height - cutOutSize) / 2;
    final w = (width - cutOutSize) / 2;
    final background = Paint()..color = Color.fromRGBO(0, 0, 0, overlayColor);
    final borderPaint = Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = borderWidth;
    final boxPaint = Paint()..color = Colors.transparent..style = PaintingStyle.fill;
    final cutOutRect = Rect.fromLTWH(w, h, cutOutSize, cutOutSize);

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), background);
    canvas.drawPath(Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))), boxPaint);
    canvas.drawPath(Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))), borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}

class ProductForm extends StatefulWidget {
  final ScrollController scrollController;
  final Product? product;
  final String? qrCode;
  const ProductForm({super.key, required this.scrollController, this.product, this.qrCode});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _quantity, _price, _shelfNumber;
  DocumentReference? _categoryRef;
  bool _isLoading = false;
  late bool _isUpdating;

  @override
  void initState() {
    super.initState();
    _isUpdating = widget.product != null;
    _name = TextEditingController(text: widget.product?.name ?? '');
    _quantity = TextEditingController(text: widget.product?.quantity.toString() ?? '');
    _price = TextEditingController(text: widget.product?.price.toString() ?? '');
    _shelfNumber = TextEditingController(text: widget.product?.numeroEstante ?? '');
    _categoryRef = widget.product?.category;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    final productData = Product(
      id: _isUpdating ? widget.product!.id : _name.text, // Use existing ID on update, new name on add
      name: _name.text,
      code: widget.qrCode,
      category: _categoryRef!,
      quantity: int.parse(_quantity.text),
      price: double.parse(_price.text),
      numeroEstante: _shelfNumber.text,
      fechaIngreso: widget.product?.fechaIngreso ?? Timestamp.now(),
      enteredBy: user?.email, // Email is used to fetch the name in FirestoreService
    );

    try {
      if (_isUpdating) {
        await FirestoreService().updateProduct(productData);
      } else {
        await FirestoreService().addProduct(productData);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al guardar: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Text(_isUpdating ? 'Editar Producto' : 'Añadir Producto', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Form(
                key: _formKey,
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (w) => SlideAnimation(verticalOffset: 50, child: FadeInAnimation(child: w)),
                      children: [
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: 'Nombre'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          readOnly: _isUpdating, // Make name non-editable on update
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<DocumentSnapshot>>(
                          stream: FirestoreService().getCategories(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                            return DropdownButtonFormField<DocumentReference>(
                              value: _categoryRef,
                              decoration: const InputDecoration(labelText: 'Categoría'),
                              items: snapshot.data!.map((doc) => DropdownMenuItem(value: doc.reference, child: Text((doc.data() as Map)['nombrecategoria']))).toList(),
                              onChanged: (v) => setState(() => _categoryRef = v),
                              validator: (v) => v == null ? 'Requerido' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(controller: _quantity, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _shelfNumber, decoration: const InputDecoration(labelText: 'Número de Estante'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _saveProduct, child: const Text('Guardar')),
                  ],
                )
        ],
      ),
    );
  }
}

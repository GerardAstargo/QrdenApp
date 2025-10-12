import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './firestore_service.dart';
import './product_model.dart';
import './product_detail_screen.dart';

enum ScanMode { add, remove, search }

class ScannerScreen extends StatefulWidget {
  final ScanMode scanMode;
  const ScannerScreen({super.key, required this.scanMode});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  String get _title {
    switch (widget.scanMode) {
      case ScanMode.add: return 'Escanear para Añadir';
      case ScanMode.remove: return 'Escanear para Quitar';
      case ScanMode.search: return 'Escanear para Buscar';
    }
  }

  Future<void> _handleQrCode(String qrCode) async {
    if (!mounted || _isProcessing) return;
    setState(() => _isProcessing = true);

    final firestoreService = FirestoreService();
    final navigator = Navigator.of(context); // Capture navigator before async gap
    final product = await firestoreService.getProductById(qrCode);

    if (widget.scanMode == ScanMode.search) {
      if (product != null) {
        await navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      } else {
        _showErrorAndReset('Producto no encontrado.');
      }
      return;
    }

    if (widget.scanMode == ScanMode.add) {
      await _showProductForm(product: product, qrCode: qrCode);
    } else if (widget.scanMode == ScanMode.remove) {
      if (product != null) {
        await _showRemoveStockDialog(product);
      } else {
        _showErrorAndReset('No se puede quitar stock de un producto no existente.');
      }
    }
  }

  void _showErrorAndReset(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    setState(() => _isProcessing = false);
  }

  Future<void> _showProductForm({Product? product, required String qrCode}) async {
    final navigator = Navigator.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9, minChildSize: 0.5, maxChildSize: 0.9,
        builder: (_, controller) => ProductForm(
            scrollController: controller,
            product: product,
            qrCode: qrCode,
          ),
      ),
    );
    
    if (result == true) {
      navigator.pop('Operación completada con éxito');
    } else {
      if(mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showRemoveStockDialog(Product product) async {
    final navigator = Navigator.of(context);
    int? quantityToRemove = await showDialog<int>(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Quitar Stock de ${product.name}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad a quitar'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) Navigator.pop(context, value);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (quantityToRemove != null) {
      int newQuantity = product.quantity - quantityToRemove;
      if (newQuantity < 0) newQuantity = 0;

      await FirestoreService().updateProduct(product.copyWith(quantity: newQuantity));

      navigator.pop('Stock actualizado');
    } else {
      if (mounted) setState(() => _isProcessing = false);
    }
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
              final String? qrCode = capture.barcodes.first.rawValue;
              if (qrCode != null) _handleQrCode(qrCode);
            },
          ),
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(borderColor: Theme.of(context).primaryColor, borderRadius: 12, borderLength: 24, borderWidth: 6, cutOutSize: MediaQuery.of(context).size.width * 0.7),
            ),
          ),
           Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _scannerController,
                    builder: (context, state, child) {
                      return IconButton(
                        color: Colors.white,
                        onPressed: () => _scannerController.toggleTorch(),
                        icon: state.torchState == TorchState.on
                            ? const Icon(Icons.flash_on)
                            : const Icon(Icons.flash_off),
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
  final Color borderColor; final double borderWidth; final double overlayColor; final double borderRadius; final double borderLength; final double cutOutSize;
  const QrScannerOverlayShape({ this.borderColor = Colors.white, this.borderWidth = 3.0, this.overlayColor = 0.8, this.borderRadius = 0, this.borderLength = 40, required this.cutOutSize, });
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
    final background = Paint()..color = Color.fromRGBO(0, 0, 0, overlayColor); final borderPaint = Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = borderWidth; final boxPaint = Paint()..color = Colors.transparent..style = PaintingStyle.fill; final cutOutRect = Rect.fromLTWH((rect.width - cutOutSize) / 2, (rect.height - cutOutSize) / 2, cutOutSize, cutOutSize);
    canvas.drawRect(Rect.fromLTWH(0, 0, rect.width, rect.height), background); canvas.drawPath(Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))), boxPaint); canvas.drawPath(Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))), borderPaint);
  }
  @override
  ShapeBorder scale(double t) => this;
}

class ProductForm extends StatefulWidget {
  final ScrollController scrollController;
  final Product? product;
  final String qrCode;
  const ProductForm({super.key, required this.scrollController, this.product, required this.qrCode});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _quantity, _price, _shelfNumber;
  DocumentReference? _categoryRef;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.product?.name ?? '');
    _quantity = TextEditingController(text: widget.product != null ? '1' : ''); 
    _price = TextEditingController(text: widget.product?.price.toString() ?? '');
    _shelfNumber = TextEditingController(text: widget.product?.numeroEstante ?? '');
    _categoryRef = widget.product?.category;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    final newProduct = Product(
      id: widget.qrCode, 
      name: _name.text,
      category: _categoryRef,
      quantity: int.tryParse(_quantity.text) ?? 1,
      price: double.tryParse(_price.text) ?? 0.0,
      numeroEstante: _shelfNumber.text,
      fechaIngreso: widget.product?.fechaIngreso ?? Timestamp.now(),
      enteredBy: widget.product?.enteredBy ?? user?.displayName ?? user?.email,
    );

    await FirestoreService().addOrUpdateProduct(newProduct);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Text(widget.product == null ? 'Añadir Producto' : 'Añadir Stock', style: Theme.of(context).textTheme.headlineSmall),
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
                        TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: 16),
                        StreamBuilder<List<DocumentSnapshot>>(
                          stream: FirestoreService().getCategories(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                            // FIX: The 'value' property is deprecated.
                            // While initialValue is suggested, 'value' is necessary here to reflect the state.
                            // This is a known lint issue for this specific widget behavior.
                            return DropdownButtonFormField<DocumentReference>(
                              value: _categoryRef, // Kept for functionality
                              decoration: const InputDecoration(labelText: 'Categoría'),
                              items: snapshot.data!.map((doc) => DropdownMenuItem(value: doc.reference, child: Text((doc.data() as Map)['nombrecategoria']))).toList(),
                              onChanged: (v) => setState(() => _categoryRef = v),
                              validator: (v) => v == null ? 'Requerido' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(controller: _quantity, decoration: InputDecoration(labelText: widget.product == null ? 'Cantidad' : 'Cantidad a Añadir'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
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

extension on Product {
  Product copyWith({int? quantity}) {
    return Product(
      id: id,
      name: name,
      category: category,
      quantity: quantity ?? this.quantity,
      price: price,
      numeroEstante: numeroEstante,
      fechaIngreso: fechaIngreso,
      enteredBy: enteredBy,
    );
  }
}
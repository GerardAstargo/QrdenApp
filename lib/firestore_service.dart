import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import './qr_code_record_model.dart'; // Import the new model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _productsCollection = 'producto';
  final String _generatedQrsCollection = 'generated_qrs';

  // Stream to get all products from the collection
  Stream<List<Product>> getProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Get a single product by its ID
  Future<Product?> getProductById(String id) async {
    final snapshot = await _db.collection(_productsCollection).doc(id).get();
    if (snapshot.exists) {
      return Product.fromFirestore(snapshot);
    }
    return null;
  }

  // Add a new product
  Future<void> addProduct(Product product) {
    return _db.collection(_productsCollection).doc(product.id).set(product.toFirestore());
  }

  // Delete a product by its ID
  Future<void> deleteProduct(String id) {
    return _db.collection(_productsCollection).doc(id).delete();
  }

  // Update an entire product
  Future<void> updateProduct(Product product) {
    return _db.collection(_productsCollection).doc(product.id).update(product.toFirestore());
  }

  // Method to save a newly generated QR code
  Future<void> saveGeneratedQr(String qrCode) {
    return _db.collection(_generatedQrsCollection).add({
      'code': qrCode,
      'generatedAt': Timestamp.now(),
    });
  }

  // Stream to get all generated QR codes, ordered by most recent
  Stream<List<QrCodeRecord>> getGeneratedQrs() {
    return _db
        .collection(_generatedQrsCollection)
        .orderBy('generatedAt', descending: true) // Order by date, newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QrCodeRecord.fromFirestore(doc))
            .toList());
  }

  // This method is kept for legacy or specific stock-only updates if needed elsewhere.
  Future<void> updateStock(String id, int newQuantity) {
    return _db.collection(_productsCollection).doc(id).update({'stock': newQuantity});
  }
}

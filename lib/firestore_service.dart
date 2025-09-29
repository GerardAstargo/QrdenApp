import 'dart:convert'; // Import for base64 encoding
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import './qr_code_record_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _generatedQrsCollection = 'generated_qrs';

  // ... (product methods remain the same) ...
  Stream<List<Product>> getProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<Product?> getProductById(String id) async {
    final snapshot = await _db.collection(_productsCollection).doc(id).get();
    if (snapshot.exists) {
      return Product.fromFirestore(snapshot);
    }
    return null;
  }

  Future<void> addProduct(Product product) {
    return _db.collection(_productsCollection).doc(product.id).set(product.toFirestore());
  }

  Future<void> deleteProduct(String id) {
    return _db.collection(_productsCollection).doc(id).delete();
  }

  Future<void> updateProduct(Product product) {
    return _db.collection(_productsCollection).doc(product.id).update(product.toFirestore());
  }

  // New method to save QR code data and its Base64 image string
  Future<void> saveGeneratedQrAsBase64(String qrCode, Uint8List imageData) async {
    // 1. Convert image data to a Base64 string
    final String imageBase64 = base64Encode(imageData);

    // 2. Save the code and the Base64 string to Firestore
    await _db.collection(_generatedQrsCollection).add({
      'code': qrCode,
      'imageBase64': imageBase64, // Store the Base64 string
      'generatedAt': Timestamp.now(),
    });
  }

  // Stream to get all generated QR codes
  Stream<List<QrCodeRecord>> getGeneratedQrs() {
    return _db
        .collection(_generatedQrsCollection)
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => QrCodeRecord.fromFirestore(doc)).toList());
  }

  Future<void> updateStock(String id, int newQuantity) {
    return _db.collection(_productsCollection).doc(id).update({'stock': newQuantity});
  }
}

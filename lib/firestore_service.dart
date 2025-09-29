import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import './product_model.dart';
import './qr_code_record_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instance of Firebase Storage

  final String _productsCollection = 'producto';
  final String _generatedQrsCollection = 'generated_qrs';

  // ... (product methods remain the same) ...
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


  // Private method to upload QR image to Firebase Storage
  Future<String> _uploadQrImage(Uint8List imageData, String qrCode) async {
    // Create a reference to the file in Firebase Storage
    final ref = _storage.ref('qrcodes/$qrCode.png');
    // Upload the data
    final uploadTask = ref.putData(imageData);
    // Await the completion of the upload
    final snapshot = await uploadTask.whenComplete(() => {});
    // Get the download URL
    return await snapshot.ref.getDownloadURL();
  }

  // Updated method to save QR code data along with its image URL
  Future<void> saveGeneratedQrAndImage(String qrCode, Uint8List imageData) async {
    // 1. Upload the image and get the URL
    final String imageUrl = await _uploadQrImage(imageData, qrCode);

    // 2. Save the code and the image URL to Firestore
    await _db.collection(_generatedQrsCollection).add({
      'code': qrCode,
      'imageUrl': imageUrl, // Store the URL of the image
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
    // This method is kept for legacy or specific stock-only updates if needed elsewhere.
  Future<void> updateStock(String id, int newQuantity) {
    return _db.collection(_productsCollection).doc(id).update({'stock': newQuantity});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'producto'; // Define collection name once

  Future<Product?> getProduct(String qrCode) async {
    final doc = await _db.collection(collectionPath).doc(qrCode).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  // Updated to write with correct Firestore field names
  Future<void> addProduct(String qrCode, String name, String description, int quantity) async {
    await _db.collection(collectionPath).doc(qrCode).set({
      'nombreproducto': name,
      'categoria': description, // Using description as category for now
      'stock': quantity,
      'codigo': qrCode, // Assuming the qrCode is the 'codigo'
      'fechaingreso': FieldValue.serverTimestamp(), // Set the date on creation
    });
  }

  // Updated to write with correct Firestore field names
  Future<void> updateProductQuantity(String qrCode, int newQuantity) async {
    await _db.collection(collectionPath).doc(qrCode).update({
      'stock': newQuantity,
    });
  }

  Future<void> deleteProduct(String qrCode) async {
    await _db.collection(collectionPath).doc(qrCode).delete();
  }

  Stream<List<Product>> getProducts() {
    return _db.collection(collectionPath).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }
}

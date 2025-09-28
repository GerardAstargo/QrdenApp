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

  // Updated to accept and save the 'precio' field
  Future<void> addProduct(String qrCode, String name, String description, int quantity, double price) async {
    await _db.collection(collectionPath).doc(qrCode).set({
      'nombreproducto': name,
      'categoria': description,
      'stock': quantity,
      'codigo': qrCode, 
      'precio': price, // Saving the price
      'fechaingreso': FieldValue.serverTimestamp(), 
    });
  }

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

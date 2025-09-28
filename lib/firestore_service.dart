import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Product?> getProduct(String qrCode) async {
    final doc = await _db.collection('products').doc(qrCode).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  Future<void> addProduct(String qrCode, String name, String description, int quantity) async {
    await _db.collection('products').doc(qrCode).set({
      'name': name,
      'description': description,
      'quantity': quantity,
    });
  }

  Future<void> updateProductQuantity(String qrCode, int newQuantity) async {
    await _db.collection('products').doc(qrCode).update({'quantity': newQuantity});
  }

  Future<void> deleteProduct(String qrCode) async {
    await _db.collection('products').doc(qrCode).delete();
  }

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }
}

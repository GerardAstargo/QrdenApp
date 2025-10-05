import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import 'dart:async';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _categoriesCollection = 'categoria'; // Collection for categories

  Stream<List<Product>> getProducts() {
    final stream = _db.collection(_productsCollection).snapshots();

    return stream.map((snapshot) {
      final List<Product> products = [];
      for (var doc in snapshot.docs) {
        try {
          products.add(Product.fromFirestore(doc));
        } catch (e, s) {
          developer.log(
            'Failed to parse product with ID: ${doc.id}',
            name: 'FirestoreService.getProducts',
            error: e,
            stackTrace: s,
          );
        }
      }
      return products;
    });
  }

  Stream<List<DocumentSnapshot>> getCategories() {
    return _db.collection(_categoriesCollection).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<Product?> getProductById(String id) async {
    final snapshot = await _db.collection(_productsCollection).doc(id).get();
    if (snapshot.exists) {
      try {
        return Product.fromFirestore(snapshot);
      } catch (e, s) {
        developer.log(
          'Failed to parse product from getProductById: ${snapshot.id}',
          name: 'FirestoreService.getProductById',
          error: e,
          stackTrace: s,
        );
        return null;
      }
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

  Future<void> updateStock(String id, int newQuantity) {
    return _db.collection(_productsCollection).doc(id).update({'stock': newQuantity});
  }
}

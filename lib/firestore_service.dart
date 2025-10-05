import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import 'dart:async'; // Import for StreamController if needed, though not required for this fix

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _categoriesCollection = 'categoria'; // Collection for categories

  // Rewritten for maximum type safety
  Stream<List<Product>> getProducts() {
    final stream = _db.collection(_productsCollection).snapshots();

    return stream.map((snapshot) {
      final List<Product> products = [];
      for (var doc in snapshot.docs) {
        try {
          // Explicitly call the robust factory constructor
          products.add(Product.fromFirestore(doc));
        } catch (e) {
          // Log or handle the error for the specific document that failed
          // This ensures that one bad document doesn't break the entire list
          print('Failed to parse product with ID: ${doc.id}. Error: $e');
        }
      }
      return products;
    });
  }

  // Function to get the stream of categories
  Stream<List<DocumentSnapshot>> getCategories() {
    return _db.collection(_categoriesCollection).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<Product?> getProductById(String id) async {
    final snapshot = await _db.collection(_productsCollection).doc(id).get();
    if (snapshot.exists) {
      try {
        return Product.fromFirestore(snapshot);
      } catch (e) {
        print('Failed to parse product from getProductById: ${snapshot.id}. Error: $e');
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

import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'producto';

  // Stream to get all products from the collection
  Stream<List<Product>> getProducts() {
    return _db.collection(_collectionName).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Get a single product by its ID
  Future<Product?> getProductById(String id) async {
    final snapshot = await _db.collection(_collectionName).doc(id).get();
    if (snapshot.exists) {
      return Product.fromFirestore(snapshot);
    }
    return null;
  }

  // Add a new product
  Future<void> addProduct(Product product) {
    // Uses the new toFirestore() method from the Product model
    return _db.collection(_collectionName).doc(product.id).set(product.toFirestore());
  }

  // Delete a product by its ID
  Future<void> deleteProduct(String id) {
    return _db.collection(_collectionName).doc(id).delete();
  }

  // Update an entire product
  Future<void> updateProduct(Product product) {
    // Uses the new toFirestore() method to update the document
    return _db.collection(_collectionName).doc(product.id).update(product.toFirestore());
  }

  // This method is kept for legacy or specific stock-only updates if needed elsewhere.
  Future<void> updateStock(String id, int newQuantity) {
    return _db.collection(_collectionName).doc(id).update({'stock': newQuantity});
  }
}

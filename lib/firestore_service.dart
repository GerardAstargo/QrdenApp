import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import './history_model.dart';
import 'dart:async';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _categoriesCollection = 'categoria';
  final String _historyCollection = 'registro';

  // --- NEW LOGIC --- //
  
  // When a product is added, create a history entry with an entry date.
  Future<void> addProduct(Product product) async {
    // Create the main product entry
    final productRef = _db.collection(_productsCollection).doc(product.id);
    await productRef.set(product.toFirestore());

    // Create the single history log for this product
    final historyRef = _db.collection(_historyCollection).doc(product.id);
    final historyData = product.toFirestore(); // Base data from product
    historyData['fecha_ingreso'] = product.fechaIngreso; // Set the entry date
    historyData['fecha_salida'] = null; // Ensure exit date is null on creation

    await historyRef.set(historyData);
  }

  // When a product is deleted, update its history entry with an exit date.
  Future<void> deleteProduct(String id) async {
    // 1. Delete the product from the main 'producto' collection
    await _db.collection(_productsCollection).doc(id).delete();

    // 2. Update the corresponding history log with the exit timestamp
    final historyRef = _db.collection(_historyCollection).doc(id);
    await historyRef.update({'fecha_salida': Timestamp.now()});
  }

  // ---UNCHANGED METHODS --- //

  Stream<List<HistoryEntry>> getHistoryEntries() {
    return _db
        .collection(_historyCollection)
        // Order by most recent entry first
        .orderBy('fecha_ingreso', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return HistoryEntry.fromFirestore(doc);
        } catch (e, s) {
          developer.log(
            'Failed to parse history entry with ID: ${doc.id}',
            name: 'FirestoreService.getHistoryEntries',
            error: e,
            stackTrace: s,
          );
          return null;
        }
      }).where((entry) => entry != null).cast<HistoryEntry>().toList();
    });
  }

  Stream<List<Product>> getProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Product.fromFirestore(doc);
        } catch (e, s) {
          developer.log(
            'Failed to parse product with ID: ${doc.id}',
            name: 'FirestoreService.getProducts',
            error: e,
            stackTrace: s,
          );
          return null;
        }
      }).where((product) => product != null).cast<Product>().toList();
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
      }
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    // Also update the history record in case product details changed
    await _db.collection(_historyCollection).doc(product.id).update(product.toFirestore());
    await _db.collection(_productsCollection).doc(product.id).update(product.toFirestore());
  }

  Future<void> updateStock(String id, int newQuantity) {
    // Also update the stock in the history record
     _db.collection(_historyCollection).doc(id).update({'stock': newQuantity});
    return _db.collection(_productsCollection).doc(id).update({'stock': newQuantity});
  }
}

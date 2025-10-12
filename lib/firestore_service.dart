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

  // --- FINAL CORRECTED LOGIC --- //

  /// Adds a product and handles stock atomically while creating a unique history record.
  Future<void> addProduct(Product product) async {
    final productRef = _db.collection(_productsCollection).doc(product.id);

    // Use a transaction to safely read and update the stock
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (snapshot.exists) {
        // If product exists, SUM the new quantity to the existing stock
        final existingStock = (snapshot.data()!['stock'] ?? 0) as int;
        final newStock = existingStock + product.quantity;
        transaction.update(productRef, {'stock': newStock});
      } else {
        // If product does not exist, create it with the initial quantity
        transaction.set(productRef, product.toFirestore());
      }
    });

    // After the transaction, create a SEPARATE and UNIQUE history entry for this batch.
    // .add() creates a new document with a unique ID.
    final historyData = product.toFirestore();
    historyData['fecha_ingreso'] = product.fechaIngreso;
    historyData['fecha_salida'] = null;
    historyData['productId'] = product.id; // Link to the main product

    await _db.collection(_historyCollection).add(historyData);
  }

  /// Deletes a product, reducing stock and marking a history entry as archived.
  Future<void> deleteProduct(String id) async {
    final productRef = _db.collection(_productsCollection).doc(id);

    // This transaction is simple: it just deletes the product summary.
    // The inventory management logic is now based on history entries.
    await _db.runTransaction((transaction) async {
      transaction.delete(productRef);
    });

    // Find the oldest active history entry for this product ID to mark as 'exited'
    final querySnapshot = await _db
        .collection(_historyCollection)
        .where('productId', isEqualTo: id)
        .where('fecha_salida', isEqualTo: null)
        .orderBy('fecha_ingreso')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final historyDocToUpdate = querySnapshot.docs.first.reference;
      await historyDocToUpdate.update({'fecha_salida': Timestamp.now()});
    }
  }

  // --- UNCHANGED OR MINOR CHANGES --- //

  Stream<List<HistoryEntry>> getHistoryEntries() {
    return _db
        .collection(_historyCollection)
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
          'Failed to parse product: ${snapshot.id}',
          name: 'FirestoreService.getProductById',
          error: e,
          stackTrace: s,
        );
      }
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection(_productsCollection).doc(product.id).update(product.toFirestore());
  }

  Future<void> updateStock(String id, int newQuantity) {
    return _db.collection(_productsCollection).doc(id).update({'stock': newQuantity});
  }
}

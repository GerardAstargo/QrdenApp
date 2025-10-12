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

  Future<void> _logAction(Product product, String action) async {
    try {
      final historyData = product.toFirestore();
      historyData['accion'] = action;
      historyData['fecha_movimiento'] = Timestamp.now();
      historyData['fecha_ingreso_original'] = product.fechaIngreso;
      await _db.collection(_historyCollection).add(historyData);
    } catch (e, s) {
      developer.log(
        'Failed to log action: $action for product: ${product.id}',
        name: 'FirestoreService._logAction',
        error: e,
        stackTrace: s,
      );
    }
  }

  Stream<List<HistoryEntry>> getHistoryEntries() {
    return _db
        .collection(_historyCollection)
        .orderBy('fecha_movimiento', descending: true)
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

  Future<void> addProduct(Product product) async {
    await _db.collection(_productsCollection).doc(product.id).set(product.toFirestore());
    await _logAction(product, 'entrada');
  }

  Future<void> deleteProduct(String id) async {
    final productToDelete = await getProductById(id);
    if (productToDelete != null) {
      await _logAction(productToDelete, 'salida');
    }
    await _db.collection(_productsCollection).doc(id).delete();
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection(_productsCollection).doc(product.id).update(product.toFirestore());
  }

  Future<void> updateStock(String id, int newQuantity) {
    return _db.collection(_productsCollection).doc(id).update({'stock': newQuantity});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/history_model.dart';
import 'dart:async';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _categoriesCollection = 'categoria';
  final String _historyCollection = 'registro';

  Future<void> addProduct(Product product) async {
    final productRef = _db.collection(_productsCollection).doc(product.id);
    await productRef.set(product.toFirestore());

    final historyRef = _db.collection(_historyCollection).doc(product.id);
    final historyData = product.toFirestore();
    historyData['fecha_ingreso'] = product.fechaIngreso ?? FieldValue.serverTimestamp();
    historyData['fecha_salida'] = null;

    await historyRef.set(historyData);
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection(_productsCollection).doc(id).delete();
    final historyRef = _db.collection(_historyCollection).doc(id);
    await historyRef.set({'fecha_salida': Timestamp.now()}, SetOptions(merge: true));
  }

  // Method to clear the entire history collection
  Future<void> clearHistory() async {
    final historyCollection = _db.collection(_historyCollection);
    final snapshot = await historyCollection.get();

    // Use a batch to delete all documents efficiently
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

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

  Future<void> updateProduct(Product product) async {
    final historyUpdateData = {
      'nombreproducto': product.name,
      'categoria': product.category,
      'stock': product.quantity,
      'precio': product.price,
      'ingresadoPor': product.enteredBy,
    };

    final historyRef = _db.collection(_historyCollection).doc(product.id);
    await historyRef.set(historyUpdateData, SetOptions(merge: true));

    final productRef = _db.collection(_productsCollection).doc(product.id);
    await productRef.update(product.toFirestore());
  }

  Future<void> updateStock(String id, int newQuantity) async {
    final stockData = {'stock': newQuantity};
    
    final historyRef = _db.collection(_historyCollection).doc(id);
    await historyRef.set(stockData, SetOptions(merge: true));

    final productRef = _db.collection(_productsCollection).doc(id);
    await productRef.update(stockData);
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
}

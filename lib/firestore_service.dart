import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import './history_model.dart'; // <- Added this missing import
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _categoriesCollection = 'categoria';
  final String _historyCollection = 'registro';

  Future<void> addOrUpdateProduct(Product product) async {
    final productRef = _db.collection(_productsCollection).doc(product.id);

    await _db.runTransaction((transaction) async {
      final productSnapshot = await transaction.get(productRef);

      if (productSnapshot.exists) {
        int newQuantity = (productSnapshot.data()!['stock'] ?? 0) + product.quantity;
        transaction.update(productRef, {
          'stock': newQuantity,
          'nombre': product.name,
          'categoria': product.category,
          'precio': product.price,
          'numero_estante': product.numeroEstante,
        });
      } else {
        transaction.set(productRef, product.toFirestore());
      }

      final historyRef = _db.collection(_historyCollection).doc();
      transaction.set(historyRef, {
        'id': product.id,
        'nombre': product.name,
        'stock': product.quantity,
        'precio': product.price,
        'fecha_ingreso': FieldValue.serverTimestamp(),
        'fecha_salida': null,
        'ingresado_por': product.enteredBy,
      });
    });
  }

  Future<void> archiveProduct(String productId) async {
    final querySnapshot = await _db
        .collection(_historyCollection)
        .where('id', isEqualTo: productId)
        .where('fecha_salida', isEqualTo: null)
        .get();

    final now = Timestamp.now();
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'fecha_salida': now});
    }
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection(_productsCollection).doc(product.id).update(product.toFirestore());
  }

  Stream<List<Product>> getProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      } catch (e) {
        return [];
      }
    });
  }

  // Corrected the return type to use the now-imported HistoryEntry
  Stream<List<HistoryEntry>> getHistoryEntries() {
    return _db
        .collection(_historyCollection)
        .orderBy('fecha_ingreso', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => HistoryEntry.fromFirestore(doc)).toList();
      } catch (e) {
        return [];
      }
    });
  }

  Stream<List<DocumentSnapshot>> getCategories() {
    return _db.collection(_categoriesCollection).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await _db.collection(_productsCollection).doc(productId).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }
}

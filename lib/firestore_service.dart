import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // PRODUCTS
  Stream<List<Product>> getProducts() {
    return _db.collection('products').where('isArchived', isEqualTo: false).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    return doc.exists ? Product.fromFirestore(doc) : null;
  }

  Future<void> addOrUpdateProduct(Product product) async {
    try {
      final existingProductDoc = await _db.collection('products').doc(product.id).get();
      final user = _auth.currentUser;
      String logMessage;

      if (existingProductDoc.exists) {
        final existingProduct = Product.fromFirestore(existingProductDoc);
        final newQuantity = existingProduct.quantity + product.quantity;
        await _db.collection('products').doc(product.id).update({
          ...product.toFirestore(),
          'quantity': newQuantity,
        });
        logMessage = 'Añadido stock de ${product.quantity} a \'${product.name}\'. Nuevo stock: $newQuantity.';
      } else {
        await _db.collection('products').doc(product.id).set(product.toFirestore());
        logMessage = 'Producto \'${product.name}\' creado con stock inicial de ${product.quantity}.';
      }
      await _addHistoryEntry(logMessage, user, product.id);
    } catch (e, s) {
      developer.log('Error in addOrUpdateProduct', name: 'FirestoreService', error: e, stackTrace: s);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _db.collection('products').doc(product.id).update(product.toFirestore());
      final user = _auth.currentUser;
      final logMessage = 'Producto \'${product.name}\' actualizado. Stock: ${product.quantity}, Precio: ${product.price}.';
      await _addHistoryEntry(logMessage, user, product.id);
    } catch (e, s) {
      developer.log('Error in updateProduct', name: 'FirestoreService', error: e, stackTrace: s);
    }
  }

  Future<void> deleteProduct(String productId, String productName) async {
    try {
      await _db.collection('products').doc(productId).delete();
      final user = _auth.currentUser;
      final logMessage = 'Producto \'$productName\' ha sido eliminado permanentemente.';
      await _addHistoryEntry(logMessage, user, productId);
    } catch (e, s) {
      developer.log('Error in deleteProduct', name: 'FirestoreService', error: e, stackTrace: s);
    }
  }

  // CATEGORIES
  Stream<List<DocumentSnapshot>> getCategories() {
    return _db.collection('categories').orderBy('nombrecategoria').snapshots().map((snapshot) => snapshot.docs);
  }

  // HISTORY
  Stream<QuerySnapshot> getHistory() {
    return _db.collection('history').orderBy('timestamp', descending: true).limit(100).snapshots();
  }

  Future<void> _addHistoryEntry(String action, User? user, String productId) async {
    if (user == null) return;
    try {
      await _db.collection('history').add({
        'action': action,
        'user': user.email ?? 'Desconocido',
        'timestamp': FieldValue.serverTimestamp(),
        'productId': productId,
      });
    } catch (e, s) {
      developer.log('Error in _addHistoryEntry', name: 'FirestoreService', error: e, stackTrace: s);
    }
  }
}

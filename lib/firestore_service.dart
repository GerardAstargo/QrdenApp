import 'package:cloud_firestore/cloud_firestore.dart';
import './product_model.dart';
import './history_model.dart';
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _productsCollection = 'producto';
  final String _categoriesCollection = 'categoria';
  final String _historyCollection = 'registro';

  Future<void> addProduct(Product product) async {
    final productRef = _db.collection(_productsCollection).doc(product.internalId);
    await productRef.set(product.toFirestore());

    final historyData = {
      ...product.toFirestore(),
      'internalId': product.internalId,
      'fecha_ingreso': product.fechaIngreso ?? FieldValue.serverTimestamp(),
      'fecha_salida': null,
    };
    await _db.collection(_historyCollection).add(historyData);
  }

  Future<void> deleteProduct(String internalId) async {
    await _db.collection(_productsCollection).doc(internalId).delete();

    final querySnapshot = await _db
        .collection(_historyCollection)
        .where('internalId', isEqualTo: internalId)
        .where('fecha_salida', isEqualTo: null)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({'fecha_salida': Timestamp.now()});
    }
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection(_productsCollection).doc(product.internalId).update(product.toFirestore());

    final querySnapshot = await _db
        .collection(_historyCollection)
        .where('internalId', isEqualTo: product.internalId)
        .where('fecha_salida', isEqualTo: null)
        .limit(1)
        .get();
    
    if(querySnapshot.docs.isNotEmpty){
      await querySnapshot.docs.first.reference.update(product.toFirestore());
    }
  }

  Future<void> updateStock(String internalId, int newQuantity) async {
    await _db.collection(_productsCollection).doc(internalId).update({'stock': newQuantity});
     final querySnapshot = await _db
        .collection(_historyCollection)
        .where('internalId', isEqualTo: internalId)
        .where('fecha_salida', isEqualTo: null)
        .limit(1)
        .get();
    
    if(querySnapshot.docs.isNotEmpty){
      await querySnapshot.docs.first.reference.update({'stock': newQuantity});
    }
  }

  Stream<List<Product>> getProducts() {
    return _db.collection(_productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Stream<List<HistoryEntry>> getHistoryEntries() {
    return _db
        .collection(_historyCollection)
        .orderBy('fecha_ingreso', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => HistoryEntry.fromFirestore(doc)).toList();
    });
  }

  Stream<List<DocumentSnapshot>> getCategories() {
    return _db.collection(_categoriesCollection).snapshots().map((snapshot) => snapshot.docs);
  }

  Future<Product?> getProductById(String internalId) async {
    final snapshot = await _db.collection(_productsCollection).doc(internalId).get();
    if (snapshot.exists) {
      return Product.fromFirestore(snapshot);
    }
    return null;
  }
}
